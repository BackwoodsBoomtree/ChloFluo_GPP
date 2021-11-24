###############################################################################
#
# Determine Topt, Tmin, and Tmax 
#
# Input is MCD12C1 using IGBP majority land cover layer
#
# Output is one file for each year for each Topt, Tmin, and Tmax.
#
###############################################################################

using GMT
using NCDatasets
using StatsBase
include("save/save_nc.jl")
# using Colors, Plots

input_land   = "/mnt/g/ChloFluo/input/landcover/mcd12c1/MCD12C1.A2019001.006.2020220162300.hdf";
input_c4veg  = 
input_c4crop = 
output_lue = "/mnt/g/ChloFluo/input/LUE/5km/lue.5km.2019.nc";

LUToptT = Dict([(0 => 30), (1 => 20), (2 => 28), (3 => 20), (4 => 20), (5 => 19), (6 => 25), (7 => 31), (8 => 24), (9 => 30), (10 => 27), (11 => 20), (12 => 30), (13 => 27), (14 => 27), (15 => 20), (16 => 30)]);
LUTminT = Dict([(0 => 0), (1 => -1), (2 => 2), (3 => -1), (4 => -1), (5 => -1), (6 => -1), (7 => 1), (8 => -1), (9 => 1), (10 => 0), (11 => 0), (12 => -1), (13 => -1), (14 => 0), (15 => 0), (16 => 0)]);
LUTmaxT = Dict([(0 => 48), (1 => 40), (2 => 48), (3 => 40), (4 => 40), (5 => 48), (6 => 48), (7 => 48), (8 => 48), (9 => 48), (10 => 48), (11 => 48), (12 => 48), (13 => 48), (14 => 48), (15 => 40), (16 => 48)]);

full_path = input_hdf * "=gd?HDF4_EOS:EOS_GRID:\"" * input_hdf * "\":MOD12C1:Majority_Land_Cover_Type_1";

land = gmt("read -Tg " * full_path);

optT_map = [LUToptT[value] for value in land];
minT_map = [LUTminT[value] for value in land];
maxT_map = [LUTmaxT[value] for value in land];

save_nc(optT_map, output_opt, "topt", "Optimum Temperature");
save_nc(minT_map, output_min, "tmin", "Minimum Temperature");
save_nc(maxT_map, output_max, "tmax", "Maximum Temperature");

# Take a look
# heatmap(maxT_map, bg = :white, color = :viridis)

