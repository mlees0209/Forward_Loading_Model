#!/bin/bash

### Takes a text file of lat/lon/Deformation and creates a kml for it.

textfile1=$1
pixelsize=$2 # suffix k means it's in kilometres. This really corresponds to grid spacing. I calculated this as the maximum delta longitude is 0.016, and multiplied by 111km. And added a bit to fill in holes... Approximate!
outputname=$3 # output is put in outputname ..

#!# Main code - edit with plenty of fear that everything might break! #!#

gmt kml2gmt ../Polygons/monster_sierras_polygon.kml -Fp -V > region.tmp

lons=`(gmt info region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

reg=-R$lons/$lats



gmt xyz2grd $textfile1 -Ggrid.tmp.nc -I$pixelsize $reg -V


gmt set PS_MEDIA A2
proj='-JX15i'

gmt set MAP_GRID_PEN_PRIMARY 0.5p,white,-
gmt set FONT_LABEL 16p,white
gmt set FONT_ANNOT_PRIMARY 16p,white


gmt makecpt -Cdrywet -T0/0.001/50+ > colours.tmp.cpt

gmt psbasemap $proj $reg -BSWne -Bxya --MAP_FRAME_TYPE=inside -V -K > $outputname.ps

gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/SouthCentralValley_zoom10.tif $proj -D -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.
gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/NorthCentralValleyBIGGER_zoom10.tif $proj -D -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.


gmt grdimage grid.tmp.nc $reg $proj -Q -O -K -Ccolours.tmp.cpt -n+c >> $outputname.ps
#gmt grdcontour grid.tmp.nc $proj -A0.005+gwhite@20+f26p+u"m" -Gd25 -C0.005 -W4.0p,black -O -V >> $outputname.ps  


gmt psscale -DjBL+w4i/0.3i+h+o2.0i/7.2i -Ccolours.tmp.cpt -R -J -F+gblack@20 -Baf+l"Subsidence (metres)" -O >> $outputname.ps


#echo $title | gmt pstext $reg $proj -F+cTL -D1/-1 -P -O >> $outputname.ps


gmt psconvert $outputname.ps -TG -E500 -W+k+t$outputname+l256/-1 -V

#rm *tmp*
rm $outputname.ps

open $outputname.png


# Make a 3D view, with fake topography which is actually the deformation.

# gmt set PS_MEDIA A2
# proj='-JM13i'
# 
# gmt set MAP_GRID_PEN_PRIMARY 0.5p,black,-
# gmt set FONT_LABEL 16p,black
# gmt set FONT_ANNOT_PRIMARY 16p,black
# 
# 
# gmt makecpt -Cdrywet -T-0.02/0/50+ > colours.tmp.cpt
# gmt grdmath grid.tmp.nc -1 MUL = grid.tmp.nc
# 
# gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/SouthCentralValley_zoom10.tif $proj -p -D -t2 $reg -B2 -BNEsw -V -K > test3d.ps # plot background satellite image, can change zoom here if u want.
# gmt grdview grid.tmp.nc $reg/-0.02/0 $proj -JZ5 -p200/45 -N-0.02+glightgray -B2 -BSWnez -Qs -Ccolours.tmp.cpt -I+a225+nt0.75 -V -O -K >> test3d.ps
# gmt set FONT_LABEL 16p,white
# gmt set FONT_ANNOT_PRIMARY 16p,white
# gmt psscale -DjTR+w4i/0.3i+h+o1.5i/3.0i -Ccolours.tmp.cpt -R -J -F+gblack@20 -Baf+l"Subsidence (metres)" -O -V >> test3d.ps
# 
# gmt psconvert -A+m0.5i -E300 -TG test3d.ps
# open test3d.png