# This script creates a grid of SWE change in mass due to a change in shallow groundwater levels. Shallow means unconfined (hence specific yield is used).
#
# Inputs: 
#
# gwpolygon: a kml polygon describing where the shallow groundwater change will occur
# headchange: a float, in metres, of the head change in the groundwater polygon
# regionalpoly: the regional polygon (the area over which the final forward model will be calculated; has to be larger than gwpolygon)
# Sy: specific yield; assumed 0.2 if not specified. 

from fastkml import kml
import numpy as np
import os
import sys 

regionalpolygon=sys.argv[3]
headchange=float(sys.argv[2]) # in metres
gwpolygon=sys.argv[1]
grdsize=sys.argv[4]
specific_yield=float(sys.argv[5])
simname=sys.argv[6]

cmd='mkdir ../Outputs/'+simname+'/make_shallowgw_input'
os.system(cmd)

def import_kml_polygon(filename):
    '''import a single .kml polygon created in Google Earth. Should work in simple cases.......'''
    
    kml_file = filename # Name of the kml file
    
    # Load the file as a string, skipping the first line because for some reason fastkml cannot deal with that...
    with open(kml_file, 'rt', encoding="utf-8") as myfile:
        doc=myfile.readlines()[1:]
        myfile.close()
    doc = ''.join(doc) # gets it as a string
    
    # Using the very opaque fastkml module to parse out the features. I wonder if the length of features is 2 if it's a 2-segment line..?
    k = kml.KML()
    k.from_string(doc)
    features = list(k.features())
    
    # Extract the first feature and a LineString object corresponding to it!
    f1 = list(features[0].features())
    t = f1[0].geometry

    A = np.array(t.exterior.coords)
    Polylon = A[:,0]
    Polylat = A[:,1]
    
    return Polylon, Polylat

largeregion=import_kml_polygon('../Polygons/'+regionalpolygon)
reg="-R%.9f/%.9f/%.10f/%.10f" % (np.min(largeregion[0]),np.max(largeregion[0]),np.min(largeregion[1]),np.max(largeregion[1]))

print('Region of investigation found to be %s' % reg)

cmd="gmt kml2gmt ../Polygons/"+gwpolygon+" > ../Outputs/"+simname+"/make_shallowgw_input/gwpoly.tmp"
print(cmd)
ret=os.system(cmd)

cmd="gmt grdmask ../Outputs/%s/make_shallowgw_input/gwpoly.tmp -G../Outputs/%s/make_shallowgw_input/shallow_gw_change.grd %s -I%s -N0/0/%.2f -rp -V" % (simname,simname,reg, grdsize, headchange*specific_yield)
print(cmd)
ret=os.system(cmd)