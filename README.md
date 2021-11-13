# ChloFluo_GPP
World's First SIF-based LUE GPP Model

## NOTES

* For converting 0.05 degree NC files to 1 degree, use cdo:

cdo -b f32 -remapcon,gridfile_1.0.txt MCD43C4.A.2018.LSWI.8-day.0.05.nc MCD43C4.A.2018.LSWI.8-day.1deg.nc

remapcon is suggested to use. Also, using the flag -b f32 ensures precision by unpacking the values. The gridfile_1.0.txt can be found in the Regrid repo: https://github.com/GeoCarb-OU/Regrid_NC_CDO
