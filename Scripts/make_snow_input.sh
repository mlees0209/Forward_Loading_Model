#!/bin/bash

# This script takes gridsize and region as input, and outputs a lat/lon/mass file of snow in that region. 

snowgridsize=$1 # Grid size for the snow in gmt-speak. eg 1k means 1 km grid size; 500e means 500 metres.
region=$2 # This is the kml outlining the whole region we're interested in.
dayinmarch=$3 # 01 02 03 04 05... 30. Choose one. (eventually will handle 'date' a bit better lol)
SimName=$4

if [[ $# -eq 0 ]] ; then
	echo -e "USEAGE INSTRUCTIONS"
    head -n7 make_snow_input.sh | tail -n6
    exit 0
fi

mkdir ../Outputs/$SimName/make_snow_input


echo "Looking for raw snow data..."
raw_snow_data=/Users/mlees/Documents/RESEARCH/bigdata/SNODAS/2017/03_Mar/SWE/us_ssmv11034tS__T0001TTNATS201703$305HP001.nc

if [ -f "$raw_snow_data" ]; then
    echo "Found raw snow data at " $raw_snow_data
    else
    echo "ERROR: No data found at " $raw_snow_data 
    exit
fi


gmt kml2gmt $2 -Fp -V > ../Outputs/$SimName/make_snow_input/region.tmp

lons=`(gmt info ../Outputs/$SimName/make_snow_input/region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info ../Outputs/$SimName/make_snow_input/region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

R=-R$lons/$lats
echo "Region of investigation found to be "$R

echo "Masking raw data to region of investigation. Converting units to metres."
gmt grdmask ../Outputs/$SimName/make_snow_input/region.tmp -G../Outputs/$SimName/make_snow_input/mask.tmp -R$raw_snow_data
gmt grdmath $R ../Outputs/$SimName/make_snow_input/mask.tmp $raw_snow_data MUL = ../Outputs/$SimName/make_snow_input/clipped.tmp
gmt grdmath ../Outputs/$SimName/make_snow_input/clipped.tmp 1000 DIV = ../Outputs/$SimName/make_snow_input/clipped.tmp

echo "Resampling raw data to input resolution size of " $snowgridsize
gmt grdsample ../Outputs/$SimName/make_snow_input/clipped.tmp -G../Outputs/$SimName/make_snow_input/snow_masses_discretized.tmp.nc -I$snowgridsize $R -V

#gmt grd2xyz ../Outputs/$SimName/make_snow_input/snow_masses_discretized.tmp.nc > ../Outputs/$SimName/make_snow_input/snow_masses_discretized.tmp.txt
