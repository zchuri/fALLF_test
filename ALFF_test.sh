#!/bin/bash

# This example is run with a (already preprocessed) rest-fMRI from:
# http://fcon_1000.projects.nitrc.org/indi/pro/unam_barrios_hypnosis_index.html

# Basedir
bdir=$(dirname ${0})
# Preprocessed fMRI file (unfiltered)
bold=${bdir}/pp_fMRI.nii.gz
# Preprocessed fMRI file (filtered)
3dBandpass -prefix pp_bp_fMRI.nii.gz 0.01 0.08 ${bold}
bold_bp=${bdir}/pp_bp_fMRI.nii.gz

# Compute mask
3dAutomask -prefix mask.nii.gz ${bold}

################################################################
# Compute ALFF and fALFF - C-PAC style
# https://fcp-indi.github.io/docs/latest/user/alff

# ALFF
3dTstat -stdev -mask mask.nii.gz -prefix alff_cpac.nii.gz ${bold_bp}
# fALFF
3dTstat -stdev -mask mask.nii.gz -prefix bold_sd.nii.gz ${bold}
3dcalc -prefix falff_cpac.nii.gz -a mask.nii.gz -b alff_cpac.nii.gz -c bold_sd.nii.gz -expr '(1.0*bool(a))*((1.0*b)/(1.0*c))' -float

# ALFF z-scores
fslstats alff_cpac.nii.gz -k mask.nii.gz -m > mean_alff_cpac.txt
mean=$( cat mean_alff_cpac.txt )
fslstats alff_cpac.nii.gz -k mask.nii.gz -s > sd_alff_cpac.txt
sd=$( cat sd_alff_cpac.txt )
fslmaths alff_cpac.nii.gz -sub ${mean} -div ${sd} -mas mask.nii.gz z_alff_cpac.nii.gz
# fALFF z-scores
fslstats falff_cpac.nii.gz -k mask.nii.gz -m > mean_falff_cpac.txt
mean=$( cat mean_falff_cpac.txt )
fslstats falff_cpac.nii.gz -k mask.nii.gz -s > sd_falff_cpac.txt
sd=$( cat sd_falff_cpac.txt )
fslmaths falff_cpac.nii.gz -sub ${mean} -div ${sd} -mas mask.nii.gz z_falff_cpac.nii.gz


################################################################
# Compute ALFF and fALFF - Zou et al. (2008) style
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3902859/

# ALFF
# Power spectrum of the filtered dataset (taper=0 according to Zang et al., 2007)
3dPeriodogram -prefix bold_bp_FFT.nii.gz -taper 0 ${bold_bp}
# Square root for each frequency and average
3dcalc -prefix bold_bp_FFT_sqrt.nii.gz -a bold_bp_FFT.nii.gz -expr 'sqrt(a)'
3dTstat -mean -mask mask.nii.gz -prefix alff_zou.nii.gz bold_bp_FFT_sqrt.nii.gz

# fALFF
3dPeriodogram -prefix bold_FFT.nii.gz -taper 0 ${bold}
3dcalc -prefix bold_FFT_sqrt.nii.gz -a bold_FFT.nii.gz -expr 'sqrt(a)'
3dTstat -mean -mask mask.nii.gz -prefix bold_FFT_sqrt_mu.nii.gz bold_FFT_sqrt.nii.gz
3dcalc -prefix falff_zou.nii.gz -a mask.nii.gz -b alff_zou.nii.gz -c bold_FFT_sqrt_mu.nii.gz -expr '(1.0*bool(a))*((1.0*b)/(1.0*c))' -float

# ALFF z-scores
fslstats alff_zou.nii.gz -k mask.nii.gz -m > mean_alff_zou.txt
mean=$( cat mean_alff_zou.txt )
fslstats alff_zou.nii.gz -k mask.nii.gz -s > sd_alff_zou.txt
sd=$( cat sd_alff_zou.txt )
fslmaths alff_zou.nii.gz -sub ${mean} -div ${sd} -mas mask.nii.gz z_alff_zou.nii.gz
# fALFF z-scores
fslstats falff_zou.nii.gz -k mask.nii.gz -m > mean_falff_zou.txt
mean=$( cat mean_falff_zou.txt )
fslstats falff_zou.nii.gz -k mask.nii.gz -s > sd_falff_zou.txt
sd=$( cat sd_falff_zou.txt )
fslmaths falff_zou.nii.gz -sub ${mean} -div ${sd} -mas mask.nii.gz z_falff_zou.nii.gz


################################################################
# Compare both outputs
fslcc -p 6 z_alff_zou.nii.gz z_alff_cpac.nii.gz
fslcc -p 6 z_falff_zou.nii.gz z_falff_cpac.nii.gz

