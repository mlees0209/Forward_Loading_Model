#!/bin/bash

### Takes a text file of lat/lon/SWE and creates a kml for it.

textfile1=$1
outputname=$2 # what do you want your grids to be saved as....
largerreg=$3

#!# Main code - edit with plenty of fear that everything might break! #!#

gmt kml2gmt $largerreg -Fp -V > region.tmp

lons=`(gmt info region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

reg=-R$lons/$lats



#gmt xyz2grd $textfile1 -Ggrid.tmp.nc -I$pixelsize $reg -V


## This script plots an individual map of inSAR pixels. ML: 26/03/2019  ###

#!# Set variables - edit with relatively little fear of breaking everything... #!#

gmt set PS_MEDIA A2
proj='-JM12i'

gmt set MAP_GRID_PEN_PRIMARY 0.5p,white,-
gmt set FONT_LABEL 16p,black
gmt set FONT_ANNOT_PRIMARY 16p,black
gmt set MAP_GRID_CROSS_PEN 16p,white


gmt makecpt -Cred2green -T0/1/0.0001 -Ic > colours.cpt # ML: you need to automate this so it choses sensibly.

gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/SouthCentralValley_zoom10.tif $proj -D -t2 $reg -V -K > $outputname.ps # plot background satellite image, can change zoom here if u want.
gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/NorthCentralValleyBIGGER_zoom10.tif $proj -D -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.
#gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/NorthCentralValley_zoom10.tif $proj -D -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.
gmt psbasemap $proj $reg -BWSne -Bxya -V -O -K >> $outputname.ps

gmt grdclip $textfile1 -G$textfile1 -Si-0.0001/0.0001/NaN -V
gmt grdimage $proj $reg $textfile1 -Ccolours.cpt -t10 -Q -K -O >> $outputname.ps


gmt psscale -DjBL+w4i/0.3i+h+o0.7i/1.2i -Ccolours.cpt -R -J -F+ggrey@20 -Baf+l"SWE (metres)" -O >> $outputname.ps


#echo $title | gmt pstext $reg $proj -F+cTL -D1/-1 -P -O >> $outputname.ps


gmt psconvert $outputname.ps -TG -P -A -V


rm $outputname.ps
open $outputname.png
