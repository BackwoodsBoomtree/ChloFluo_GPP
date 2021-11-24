###############################################################################
#
# Determine LUEmax
#
# Input is MCD12C1 and ISLSCP II
#
# Output is one file for each year for each Topt, Tmin, and Tmax.
#
# Note: ISLSCP map saved to nc using qgis.
#       Might be improved in future for higher resolution using cropland maps,
#       i.e., VPM and Earth Stats
#
###############################################################################

c4_map     = "/mnt/g/ChloFluo/input/C3C4/ISLSCP/c4_percent_1d.nc";
output_nc = "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc";
y           = 2019;
var_sname   = "LUEmax";
var_lname   = "Maximum Light Use Efficiency";
unit        = "g C / mol";

# Possible future use
# input_hdf  = "/mnt/g/ChloFluo/input/landcover/mcd12c1/MCD12C1.A2018001.006.2019200161458.hdf";
# LUT_LUEe = Dict([(0 => NaN), (1 => 0.78), (2 => 0.78), (3 => 0.78), (4 => 0.78), (5 => 0.78), (6 => 0.78), (7 => 0.78), (8 => 0.78), (9 => 0.78), (10 => 0.78), (11 => 0.78), (12 => 0.78), (13 => 0.78), (14 => 0.78), (15 => 0.78), (16 => 0.78)]);
# full_path = input_hdf * "=gd?HDF4_EOS:EOS_GRID:\"" * input_hdf * "\":MOD12C1:Majority_Land_Cover_Type_1";
# land = gmt("read -Tg " * full_path);
# LUE_map = [LUT_LUEe[value] for value in land];

function calc_luemax(map)

    c4_perc = Dataset(map)["Band1"][:,:]
    c4_perc = rotr90(c4_perc)
    c4_perc = reverse!(c4_perc, dims = 2)
    c4_perc = replace!(c4_perc, missing => NaN)
    c4_perc = c4_perc / 100

    lue = (c4_perc .* 0.117) + ((1 .- c4_perc) .* 0.078)

    save_nc(lue, output_nc, y, var_sname, var_lname, unit)
end

calc_luemax(c4_map)

# Take a look
# heatmap(lue, bg = :white, color = :viridis)

