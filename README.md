# ChloFluo_GPP
World's First SIF-based LUE GPP Model

## Possible Future Improvements or Considerations

* VPM uses a complex method to derive LSWImax that involves determining the SOS and EOS for each pixel using night time temp. I did not implement this scheme here because:
  1. The maps with and without the scheme were very, very similar (I compared merged LSWImax at HD that was already available in the VPM folder to my 1 degree calculations).
  2. I want to let SIF be more deterministic of the SOS and EOS by not constraining SIF-driven GPP using night time temp. 

## NOTES

### For converting 0.05 degree NC files to 1 degree, use cdo:

* cdo -b f32 -remapcon,gridfile_1.0.txt MCD43C4.A.2018.LSWI.8-day.0.05.nc MCD43C4.A.2018.LSWI.8-day.1deg.nc

remapcon is suggested to use. Also, using the flag -b f32 ensures precision by unpacking the values. The gridfile_1.0.txt can be found in the Regrid repo: https://github.com/GeoCarb-OU/Regrid_NC_CDO. It is best to use the grid file to explicity set the extent.

### Using scale_value in NCDatasets.jl

* Do not scale the data and then try to assign a scale_value, as it breaks the fill value for some reason. Just leave data you are packing into NC in a float and use deflate to compress the data. 
