#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 09:25:06 2019

This script does the calculation in the forward model to figure out loading due to snow.

It requires three file types to have been produced by other, GMT scripts:
    MASSESFILE.txt : a file containing x,y,SWE discretised according to how you want input snow discretised.
    dXX.tmp.float : a lot of these files, where XX is the id of the snow mass in question, and the files contain x,y,DIST discretised according to the output.
    d0.tmp.txt : this contains the coordinates of the output model grid.
    SimName : this variable the pathname to where everything is contained.

@author: mlees
"""
import sys
import numpy as np
from scipy import special
import matplotlib.pyplot as plt
import matplotlib

alpha=float(sys.argv[1]) # The first argument should be disk diameter; or equivalently, pixel size of the snow grid.
lamda=float(sys.argv[2]) # The second argument should be the Lame parameter of the substrate
mu=float(sys.argv[3]) # The third argument should be the shear modulus of the substrate
massesfile=str(sys.argv[4])
SimName=str(sys.argv[5])

def calc_G(lamda, mu, alpha, r):
    ''' 
    Calculates the G transform for a disk of radius alpha at a distance r, on top of a substrate with Lame parameter lambda and shear modulus mu.
    lamda: Lame parameter of substrate
    mu: shear modulus of substrate
    alpha: disk radius, in metres
    r: array of distances from centre of disk at which to calculate solution. In metres. eg r = np.linspace(0,50*10**3,num=1000) to go to 50km distance.
    
    '''
    sigma=lamda+2*mu
    nabla=lamda + mu
    
    defm=np.zeros_like(r)
    
    r_disk = r[r<=alpha]
    r_postdisk = r[r>=alpha]
    
    
    defm[r<=alpha]=g* (sigma/(np.pi**2 * mu * nabla * alpha) * special.ellipe((r_disk/alpha)**2) )  
    
    defm[r>=alpha]=g* (sigma* r_postdisk / (np.pi**2 * mu * nabla * alpha**2)) * (special.ellipe((alpha/r_postdisk)**2) - (1 - (alpha/r_postdisk)**2) * special.ellipk((alpha/r_postdisk)**2)) 
    
    return defm


X = np.genfromtxt(massesfile) # Read in the snow masses.

g = 9.81 # gravity acceleration
#lamda = 25*10**9 # Lame parameter of granite
#mu = 40*10**9 # Shear modulus of granite
alpha = 0.5* alpha*10**3 # convert to metres
rho_water = 1000 # density of water (to convert from SWE to mass)

D0 = np.genfromtxt('../Outputs/%s/create_Ds/Ds/d0.tmp.txt' % SimName) # read in coordinates of output grid

#defms = np.zeros((len(D0),1,len(X))) # initiate deformations matrix
finaldefm = np.zeros((len(D0)))

for i in range(len(X)):
    # Loop over each mass in turn, and calculate the deformation due to that mass
    if (X[i,2]!= 0.) & (not np.isnan(X[i,2])):
        print('Calculating defm due to mass %i' % i)
        D = np.fromfile('../Outputs/%s/create_Ds/Ds/d%i.tmp.float' % (SimName,i),dtype='f4') # Read in the distances file
        G = calc_G(lamda,mu,alpha,1000*D) # Calculate G for each distance
        
        Mass = (2*alpha) **2 * X[i,2] * rho_water # Calculate the masses for the snow cell
        
        finaldefm += G*Mass # Calculate the deformations due to the snow cell
        
#        plt.figure()
#        plt.scatter(D[:,0],D[:,1],s=10,c=defm)
#        plt.colorbar()


finaldefm = finaldefm.flatten() # Sum all the deformations

finaldfm_numpyarray = np.column_stack((D0[:,0],D0[:,1],finaldefm)) # Create an array to be outputted
print('Saving output deformation from Python script. May take a while for large output grids.')
np.savetxt('../Outputs/%s/outputDeformation.txt' % SimName,finaldfm_numpyarray) # Save the result.
