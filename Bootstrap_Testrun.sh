#!/bin/bash

set -evxf

#Script to perform basic bootstrapping run with PISM on BedMachine bedrock
#topopgraphy data set, as described in the PISM manual.
#Bedrock and ice topo: Bedmachine
#Climate forcings: From SeaRISE file
#Geothermal heat flux: From Colgan et al 2022

#Remember to specify cores (with 'taskset -c corenumberfirst-corenumberlast')
#in order to make sure you are running on cores not currently in use.

#PISM executable
pismrun=pismr

#------------------------------------------------------------------------
#Files and directories

#Directory of input data
INDIR='/mnt/data/syhsv/Data/PISMIn/BedMachine/BedMachinePISM/BasalHeatFlux/Colgan/'
INNAME='pism-Greenland_BedMachine_Colgan_1km-filled-smoothed.nc'
infile=${INDIR}${INNAME}

#Directory of output data
OUTDIR='/mnt/data/syhsv/Data/PISMOut/Spinups/MACLU_Test/'
ts_file_name=${OUTDIR}'ts_g20km_test.nc'
ex_file_name=${OUTDIR}'ex_g20km_test.nc'
outfile_name=${OUTDIR}'g20km_test.nc'

#
#End, files and directories
#------------------------------------------------------------------------

#------------------------------------------------------------------------
#PISM run options

#Grid
#20k 
#GRID='Lx 766.5 -Mx 77 -Ly 137.55 -My 138 -Lz 4000 -Mz 101 -Lbz 2000 -Mbz 11'
GRID='-Mx 77 -My 138 -Lz 4500 -Mz 101 -Lbz 2000 -Mbz 11'

#Forcing
FORCING='-surface given -surface_given_file '${infile}

#Physics
PHYSICS='-bed_def lc -stress_balance ssa+sia -pseudo_plastic -pseudo_plastic_q 0.6 -stress_balance.sia.Glen_exponent 3 -stress_balance.sia_enhancement_factor 1 -stress_balance.sia.max_diffusivity 10000 -stress_balance.ssa.Glen_exponent 3.25 -stress_balance.ssa.enhancement_factor 1 -basal.resistance.beta_lateral_margin -yield_stress mohr_coulomb -topg_to_phi 5,40,-1000,700 -age.enabled'

#Calving
#CALVING='-calving float_kill -calving.float_kill.margin_only' 
CALVING='-cfbc -kill_icebergs -part_grid -subgl -calving vonmises_calving,thickness_calving -calving.thickness_calving -calving_threshold 150'

#Run period
startyear=0
endyear=2500
RUNPERIOD='-ys '$startyear' -ye '$endyear

#Output options

#Scalar output
TSFILEOPTIONS='-ts_file '$ts_file_name' -ts_times '$startyear':50:'$endyear

#2-D and 3-D output options
#EXVAR_LIST='diffusivity,temppabase,tempicethk_basal,bmelt,tillwat,velsurf_mag,mask,thk,topg,usurf'
EXVAR_LIST='topg,thk,usurf,velbar_mag,velbase_mag,velsurf_mag,tendency_of_subglacial_water_mass,tendency_of_ice_mass_due_to_surface_mass_flux,tendency_of_ice_mass_due_to_flow,tendency_of_ice_mass_due_to_discharge,tendency_of_ice_mass_due_to_calving,tendency_of_ice_mass_due_to_basal_mass_flux,tendency_of_ice_mass,temppabase,tempicethk_basal,temp,tempbase,taud_mag,tauc,taub_mag,strainheat,pressure,mask,liqfrac,heat_flux_from_bedrock,hardav,flux_mag,enthalpybase,bwat,bmelt,bheatflx,bfrict,beta,basal_melt_rate_grounded,basal_mass_flux_grounded'

EXFILEOPTIONS='-extra_file '$ex_file_name' -extra_times '$startyear':250:'$endyear' -extra_vars '$EXVAR_LIST
#
#End, PISM run options
#---------------------------------------------------------------------------

#PISM run command remember to adjust the core assignment numbers (using
#taskset -c) to unoccupied cores before submitting. -Use 'htop' to see current
#load.
mpiexec -n 8 taskset -c 1-7 $pismrun \
	-i $infile -bootstrap \
	$GRID \
	-skip -skip_max 10 \
	-grid_recompute_longitude_and_latitude false \
	-periodicity none \
	$RUNPERIOD \
	$FORCING \
	$PHYSICS \
	$CALVING \
	$TSFILEOPTIONS \
	$EXFILEOPTIONS \
	-o $outfile_name

exit

#End, script
