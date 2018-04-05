# f/ALLF test

Check two approaches to compute f/ALFF on fMRI data.
* C-PAC: taking the averaged standard deviation from the fMRI timeseries.
* Zou et al. (2008): taking averaged amplitude of the frequency spectrum.

An example file and an executable script are given to test it. AFNI and FSL softwares are need it.
Both approaches don't match perfectly but the results are highly correlated. The reason of the mismatch could be due to the digital transformation to the frequency domain.
