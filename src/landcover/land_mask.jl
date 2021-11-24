
###############################################################################
#
# Create land mask from ERA5
#
# Filters
#
###############################################################################

land_file   = "/mnt/g/ChloFluo/input/landcover/era5_land/original/ERA5.land-sea-mask.2020.nc";
output_nc   = "/mnt/g/ChloFluo/input/landcover/era5_land/original/ERA5.land-sea-mask.2020_extracted.nc";
resamp_nc   = "/mnt/g/ChloFluo/input/landcover/era5_land/1deg/ERA5.land-sea-mask.2020.1deg.nc";
year        = 2020;
var_sname   = "land";
var_lname   = "Percent Land Cover";
unit        = "%";

land = Dataset(land_file)["lsm"][:,:,1];
land = rotl90(land);

save_nc(land, output_nc, year, var_sname, var_lname, unit);

# GDAL command to resample
# run(`gdalwarp -te -180 -90 180 90 -tr 1.0 1.0 -r average -dstnodata -9999 $output_nc $resamp_nc`)

# Take a look
# heatmap(land, bg = :white, color = :viridis)