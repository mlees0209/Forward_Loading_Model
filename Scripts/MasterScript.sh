#!/bin/bash

# This master script calls the various other subroutines in order to perform the forward model for desired parameters.
# Edit the parameters here.

snowgridsize=5k
region_polygon=../Polygons/monster_sierras_polygon.kml
dayinmarch=20
outputgridsize=2.5k
lamda="15e9" # Lame parameter of granite
mu="30e9" # Shear modulus of granite

outputname='../Outputs/Deformation_grid'$outputgridsize'snowgrid'$snowgridsize'march'$dayinmarch'2017_SANDSTONE_CONTOURS'

# Don't edit below here or everything will end.



echo "./make_snow_input.sh "$snowgridsize $region_polygon $dayinmarch 
./make_snow_input.sh $snowgridsize $region_polygon $dayinmarch 

cmd='./visualise_snow_masses.sh snow_masses_discretized.tmp.txt '$snowgridsize
echo $cmd
$cmd

rm Ds/*tmp*

echo "./create_Ds.sh " $outputgridsize $region_polygon
./create_Ds.sh $outputgridsize $region_polygon

pythonsnowgridsize=$(echo $snowgridsize | rev | cut -c 2- | rev)

cmd='python run_forward_model.py '$pythonsnowgridsize' '$lamda' '$mu
echo $cmd
$cmd


cmd='./plot_resulting_model.sh outputDeformation.tmp.txt '$outputgridsize' '$outputname
echo $cmd 
$cmd


#rm *tmp* # Comment this line out, if you might want to debug or rerun earlier parts (for instance, redo any of the plots with slightly different scales, parameters, etc)
