#!/bin/bash

### Takes a grid file of lat/lon/SWE and creates a map of it.

largerreg=$1
SimName=$2
inputgrid=../Outputs/$SimName/loading_input_grid.nc

#!# Main code - edit with plenty of fear that everything might break! #!#

mkdir ../Outputs/$SimName/visualise_input_loading
filelocs='../Outputs/'$SimName'/visualise_input_loading'
outputname=$filelocs/Input_Loading_Visualisation


gmt kml2gmt $largerreg -Fp -V > $filelocs/region.tmp

lons=`(gmt info $filelocs/region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info $filelocs/region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

reg=-R$lons/$lats
echo "Region of investigation found to be "$reg

#gmt xyz2grd $textfile1 -Ggrid.tmp.nc -I$pixelsize $reg -V


## This script plots an individual map of inSAR pixels. ML: 26/03/2019  ###

#!# Set variables - edit with relatively little fear of breaking everything... #!#

gmt set PS_MEDIA A2
proj='-JM12i'

gmt set MAP_GRID_PEN_PRIMARY 0.5p,white,-
gmt set FONT_LABEL 16p,black
gmt set FONT_ANNOT_PRIMARY 16p,black

#gmt makecpt -Cred2green -T0/1/0.0001 -Ic > colours.cpt # ML: you need to automate this so it choses sensibly.

gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/SouthCentralValley_zoom10.tif $proj -t2 $reg -V -K > $outputname.ps # plot background satellite image, can change zoom here if u want.
gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/NorthCentralValleyBIGGER_zoom10.tif $proj -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.
#gmt grdimage /Users/mlees/Documents/RESEARCH/bigdata/Google_Satellite_Imagery/NorthCentralValley_zoom10.tif $proj -D -t2 $reg -V -K -O >> $outputname.ps # plot background satellite image, can change zoom here if u want.
gmt psbasemap $proj $reg -BWSne -Bxya -V -O -K >> $outputname.ps

#gmt grdclip $inputgrid -G$textfile1 -Si-0.00000001/0.000000001/NaN -V
gmt grdclip $inputgrid -G$filelocs/input_loading_grid_NAN.nc -Sr0/NaN -V # Set zero values to NaN for visualisation purposes.
gmt grdclip $filelocs/input_loading_grid_NAN.nc -G$filelocs/input_loading_grid_NAN.nc -Sb0/NaN -V # Set zero values to NaN for visualisation purposes.
gmt grd2cpt $filelocs/input_loading_grid_NAN.nc -Cred2green -E -Ic -V > $filelocs/colours.cpt

#gmt grdmath $inputgrid 0 NAN -V = $filelocs/input_loading_grid_NAN.nc
gmt grdimage $proj $reg $filelocs/input_loading_grid_NAN.nc -C$filelocs/colours.cpt -t10 -Q -O -K -V >> $outputname.ps


gmt psscale -DjBL+w4i/0.3i+h+o0.7i/1.2i -C$filelocs/colours.cpt -R -J -F+ggrey@20 -Baf+l"SWE (metres)" -O -V >> $outputname.ps


#echo $title | gmt pstext $reg $proj -F+cTL -D1/-1 -P -O >> $outputname.ps


gmt psconvert $outputname.ps -TG -P -A -V


rm $outputname.ps
open $outputname.png
