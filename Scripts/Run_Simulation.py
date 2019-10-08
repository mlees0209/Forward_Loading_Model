# This Python script is the masterscript, which should be used to run any Snow Forward Model. 
# 
# LAST UPDATED: Oct 8nd 2019
#
# The script has three sections. The first sets general parameters for your run, whilst the second and third are specific subsections depending on general options selected.
#
#
#

### SET GENERAL PARAMETERS ###

simulation_name='KingsCanyon_unconsolidated-sand' # STRING. The simulation name is the name of the folder into which results will be put.
loading_grid_size='2.5k' # STRING. Set the cell size of the grid of loads. Should be in "GMT"-speak, so with a unit of either k (km) or e (m). eg '1k' = 1km.
output_grid_size='0.5k' # STRING. Set the cell size for the output grid of deformation. Should be in "GMT"-speak, so with a unit of either k (km) or e (m). eg '1k' = 1km.
lame_param=7.4e9 # FLOAT. Set the first Lame parameter for the substrate. Units=XXXX
shear_modulus=3e9 # FLOAT. Set the shear modulus for the substrate. Units=XXXX.
region_polygon='Kings_River_Polygon.kml' # STRING. This is the filename of the kml polygon defining the entire region over which the simulation will be performed.
loading_type=["Shallow_Groundwater"] # LIST OF STRINGS. Can contain as many strings as you like. This determines what types of loading you are providing the model with. Options are: Snow, Shallow_Groundwater.
visualise_loading=0 # BOOL. Do you want to make a map visualising the input load?
visualise_output=1 # BOOL. Do you want to make a map visualising the output deformation?
distance_calculator='fast' # STRING. Either 'fast' or 'slow'. Refers to the solver for 'calc_Ds.sh'; see that script for more info. Typically you want fast.

### SET PARAMETERS RELATING TO SNOW LOADING. IF "Snow" NOT IN LOADING_TYPE, THIS SECTION IS IGNORED. ###

day_in_march='01' # STRING. Bc this code is a bit naff, it only models snow for one day in March of 2017. Choose that day. (NB days from 1-9 should be 01, 02 etc)


### SET PARAMETERES RELATING TO SHALLOW GROUNDWATER LOADING. IF "Shallow_Groundwater" NOT IN LOADING TYPE, THIS SECTION IS IGNORED. ###

gw_polygon ='gwpolygon.kml' # STRING. Filename of the kml polygon for the region experiencing a change in shallow groundwater levels.
delta_h = 2.5 # FLOAT. Change in water table of shallow groundwater in gw_polygon. Units=metres.
specific_yield=0.2 # FLOAT. Specific yield of shallow groundwater.


###!!! RUN THE MAIN CODE. DON'T EDIT THIS UNLESS YOU WANT TO ALTER THE MAIN CODE. !!!###

import os

# Make the Output folder.
print('Making directory %s in Outputs.' % simulation_name)
try:
	os.mkdir('../Outputs/%s' % simulation_name)
except OSError as error:
	print('\t %s' % error)
	print('\t Do you want to clear the existing Output with name %s? (Y/n)' % simulation_name)
	a = input()
	if a=='Y' or a=='y':
		ret=os.system('rm -r ../Outputs/%s/*' % simulation_name)
	else:
		raise Exception ('Outputs with Simulation Name already exist. Try a different name, or remove the output.')
print('\n')


# Prepare the Input Loading Grid.
if "Snow" in loading_type:
	print('Found Snow in loading_type. Preparing snow input.')
	cmd = './make_snow_input.sh %s ../Polygons/%s %s %s' % (loading_grid_size, region_polygon, day_in_march, simulation_name)
	print(cmd)
	ret=os.system(cmd)
	cmd='cp ../Outputs/%s/make_snow_input/snow_masses_discretized.tmp.nc ../Outputs/%s/loading_input_grid.nc' % (simulation_name,simulation_name)
	ret=os.system(cmd)
	print('\n')
	
if "Shallow_Groundwater" in loading_type:
	print('Found Shallow_Groundwater in loading_type. Preparing shallow groundwater input.')
	cmd = 'python make_shallowgw_input.py %s %f %s %s %f %s' % (gw_polygon,delta_h,region_polygon,loading_grid_size,specific_yield,simulation_name)
	print(cmd)
	ret=os.system(cmd)
	cmd='cp ../Outputs/%s/make_shallowgw_input/shallow_gw_change.grd ../Outputs/%s/loading_input_grid.nc' % (simulation_name,simulation_name)
	ret=os.system(cmd)
	print('\n')
	
if "Snow" in loading_type and "Shallow_Groundwater" in loading_type:
	print('Snow and Shallow_Groundwater both found in loading_type. Summing snow and shallow_groundwater to make input loading grid.')
	cmd='gmt grdmath ../Outputs/%s/make_snow_input/snow_masses_discretized.tmp.nc ../Outputs/%s/make_shallowgw_input/shallow_gw_change.grd ADD = ../Outputs/%s/loading_input_grid.nc' % (simulation_name,simulation_name,simulation_name)	
	print(cmd)
	ret=os.system(cmd)
	print('\n')
	

# Visualise the input loading grid.
if visualise_loading:
	print('Visualising input loading grid.')
	cmd='./visualise_input_loading.sh ../Polygons/%s %s' % (region_polygon, simulation_name)
	print(cmd)
	ret=os.system(cmd)
	print('\n')



# Create grids of distances.

print('Creating grids of distances.')
cmd='gmt grd2xyz ../Outputs/%s/loading_input_grid.nc > ../Outputs/%s/loading_input_text.txt' % (simulation_name,simulation_name)
ret=os.system(cmd)
cmd='./create_Ds.sh %s ../Polygons/%s ../Outputs/%s/loading_input_text.txt %s %s' % (output_grid_size, region_polygon, simulation_name, simulation_name, distance_calculator)
print(cmd)
ret=os.system(cmd)
print('\n')


# Run the forward model.
print('Running the forward model.')
cmd='python run_forward_model.py %f %f %f ../Outputs/%s/loading_input_text.txt %s' % (float(loading_grid_size[:-1]), lame_param, shear_modulus, simulation_name, simulation_name)
print(cmd)
ret=os.system(cmd)
print('\n')


# Visualise the output.
cmd='./visualise_output_deformation.sh %s ../Polygons/%s %s' % (simulation_name,region_polygon,output_grid_size)
print(cmd)
ret=os.system(cmd)