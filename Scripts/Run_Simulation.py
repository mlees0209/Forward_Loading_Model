# This Python script is the masterscript, which should be used to run any Snow Forward Model. 
# 
# LAST UPDATED: Oct 8nd 2019
#
# The script has three sections. The first sets general parameters for your run, whilst the second and third are specific subsections depending on general options selected.
#
#
#

### SET GENERAL PARAMETERS ###

simulation_name='TestRun' # STRING. The simulation name is the name of the folder into which results will be put.
loading_grid_size='1k' # STRING. Set the cell size of the grid of loads. Should be in "GMT"-speak, so with a unit of either k (km) or e (m). eg '1k' = 1km.
output_grid_size='1k' # STRING. Set the cell size for the output grid of deformation. Should be in "GMT"-speak, so with a unit of either k (km) or e (m). eg '1k' = 1km.
lame_param=4e9 # FLOAT. Set the first Lame parameter for the substrate. Units=XXXX
shear_modulus=3e9 # FLOAT. Set the shear modulus for the substrate. Units=XXXX.
region_polygon='monster_sierras_polygon.kml' # STRING. This is the filename of the kml polygon defining the entire region over which the simulation will be performed.
loading_type=["Snow","Shallow_Groundwater"] # LIST OF STRINGS. Can contain as many strings as you like. This determines what types of loading you are providing the model with. Options are: Snow, Shallow_Groundwater.
visualise_loading=1 # BOOL. Do you want to make a map visualising the input load?
visualise_output=1 # BOOL. Do you want to make a map visualising the output deformation?


### SET PARAMETERS RELATING TO SNOW LOADING. IF "Snow" NOT IN LOADING_TYPE, THIS SECTION IS IGNORED. ###

day_in_march='01' # STRING. Bc this code is a bit naff, it only models snow for one day in March of 2017. Choose that day. (NB days from 1-9 should be 01, 02 etc)


### SET PARAMETERES RELATING TO SHALLOW GROUNDWATER LOADING. IF "Shallow_Groundwater" NOT IN LOADING TYPE, THIS SECTION IS IGNORED. ###

gw_polygon ='TestGroundwaterPolygon.kml' # STRING. Filename of the kml polygon for the region experiencing a change in shallow groundwater levels.
delta_h = 2.5 # FLOAT. Change in water table of shallow groundwater in gw_polygon. Units=metres.
specific_yield=0.2 # FLOAT. Specific yield of shallow groundwater.


###!!! RUN THE MAIN CODE. DON'T EDIT THIS UNLESS YOU WANT TO ALTER THE MAIN CODE. !!!###

import os

print('Making directory %s in Outputs.' % simulation_name)
try:
	os.mkdir('../Outputs/%s' % simulation_name)
except OSError as error:
	print('\t %s' % error)
print('\n')

if "Snow" in loading_type:
	cmd = './make_snow_input.sh %s ../Polygons/%s %s %s' % (loading_grid_size, region_polygon, day_in_march, simulation_name)
	print(cmd)
	ret=os.system(cmd)
	
if "Shallow_Groundwater" in loading_type:
	cmd = 'python make_shallowgw_input.py %s %f %s $f' % (gw_polygon,delta_h,region_polygon,specific_yield)
	print(cmd)
	ret=os.system(cmd)
	
