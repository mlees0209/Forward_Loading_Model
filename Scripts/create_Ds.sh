#!/bin/bash

# This script reads in all the lat/lon coords for snow and produces grids containing distances from those points in km.

gridsize=$1
region=$2 # kml polygon enclosing the whole region.
masses=$3 # filename containing lon,lat,snowmass.
SimName=$4
mode=$5 # fast or slow

if [[ $# -eq 0 ]] ; then
	echo -e "USEAGE INSTRUCTIONS"
    head -n7 create_Ds.sh | tail -n6
    exit 0
fi

mkdir ../Outputs/$SimName/create_Ds
filelocs=../Outputs/$SimName/create_Ds
mkdir $filelocs/Ds
gmt kml2gmt $region -Fp -V > ../Outputs/$SimName/create_Ds/region.tmp

lons=`(gmt info $filelocs/region.tmp | cut -f 2 | tr -d '<' | tr -d '>')`
lats=`(gmt info $filelocs/region.tmp | cut -f 3 | tr -d '<' | tr -d '>')`

R=-R$lons/$lats
i=0

totallines=$(wc -l $masses)

if [ "$mode" == "fast" ]; then
	echo "FAST mode selected. Setting distance calculator to less accurate (10s of metres) Andoyer."
	gmt set PROJ_GEODESIC Andoyer
else
	echo "SLOW mode selected. Setting distance calculator to highly accurate (0.5 mm) Vincenty."
	gmt set PROJ_GEODESIC Vincenty
fi


echo "Output grid has pixel size of "$gridsize "; increase pixel size to reduce time taken."
echo "Setting up d0."

line=$(head -n1 $masses)
lat=$(echo $line | cut -f 2 -d ' ')
lon=$(echo $line | cut -f 1 -d ' ')
gmt grdmath -I$gridsize $R $lon $lat SDIST -V = $filelocs/dist.nc.tmp
gmt grd2xyz $filelocs/dist.nc.tmp -V > $filelocs/Ds/d$i.tmp.txt

cut -f 3 $masses > $filelocs/masses.tmp

# This loop, I am sure, could be substantially sped up if the whole thing were done in a Python script which calls the gmt commands.
while read line; do
		mass=$(echo $line | cut -f 3 -d ' ')
		if [ ! "$mass" == "0" ] && [ ! "$mass" == "NaN" ]; then
			echo "Doing line " $i " out of " $totallines"."
			lat=$(echo $line | cut -f 2 -d ' ')
			lon=$(echo $line | cut -f 1 -d ' ')
			gmt grdmath -I$gridsize $R $lon $lat SDIST = $filelocs/dist.nc.tmp
			gmt grd2xyz $filelocs/dist.nc.tmp -ZTLf > $filelocs/Ds/d$i.tmp.float
		fi
		let "i++"

done < $masses
