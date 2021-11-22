
###############################################################################
#
# Create land mask from ERA5
#
# Filters
#
###############################################################################

using NCDatasets
using Colors, Plots

include("../save/save_nc.jl")

land_file   = "/mnt/g/ChloFluo/input/landcover/era5_land/original/ERA5.land-sea-mask.2020.nc";
output_nc   = "/mnt/g/ChloFluo/input/landcover/era5_land/original/ERA5.land-sea-mask.2020_extracted.nc";
resamp_nc   = "/mnt/g/ChloFluo/input/landcover/era5_land/1deg/ERA5.land-sea-mask.2020.1deg.nc";
year        = 2020;
var_sname   = "land";
var_lname   = "Percent Land Cover";
unit        = "%";

land = Dataset(land_file)["lsm"][:,:,1];

save_nc(land, output_nc, year, var_sname, var_lname, unit);

# GDAL command to resample
run(`gdalwarp -te -180 -90 180 90 -tr 1.0 1.0 -r average -dstnodata -9999 SRC_METHOD=NO_GEOTRANSFORM $output_nc $resamp_nc`)

run(`gdalinfo $output_nc`)

test = "/mnt/g/TROPOMI/esa/gridded/1deg/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.1deg.CF80.nc";
run(`gdalinfo $test`)

# Take a look
heatmap(land, bg = :white, color = :viridis)