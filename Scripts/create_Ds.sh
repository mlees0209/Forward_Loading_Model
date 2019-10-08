#!/bin/bash

# This script reads in all the lat/lon coords for snow and produces grids containing distances from those points in km.

gridsize=$1
region=$2 # kml polygon enclosing the whole region.
masses=$3 # filename containing lon,lat,snowmass.

if [[ $# -eq 0 ]] ; then
	echo -e "USEAGE INSTRUCTIONS"
    head -n7 create_Ds.sh | tail -n6
    exit 0
fi


gmt kml2gmt $2 -Fp -V > region.tmp

lons=`(gmt info region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

R=-R$lons/$lats
i=0

totallines=$(wc -l $masses)

echo "Output grid has pixel size of "$gridsize "; increase pixel size to reduce time taken."

line=$(head -n1 $masses)
lat=$(echo $line | cut -f 2 -d ' ')
lon=$(echo $line | cut -f 1 -d ' ')
gmt grdmath -I$1 $R $lon $lat SDIST = dist.nc.tmp
gmt grd2xyz dist.nc.tmp > Ds/d$i.tmp.txt

mkdir Ds

while read line; do
		mass=$(echo $line | cut -f 3 -d ' ')
		if [ ! "$mass" == "0" ] && [ ! "$mass" == "NaN" ]; then
			echo "Doing line " $i " out of " $totallines"."
			lat=$(echo $line | cut -f 2 -d ' ')
			lon=$(echo $line | cut -f 1 -d ' ')
			gmt grdmath -I$1 $R $lon $lat SDIST = dist.nc.tmp
			gmt grd2xyz dist.nc.tmp -ZTLf > Ds/d$i.tmp.float
		fi
		let "i++"

done < $masses
