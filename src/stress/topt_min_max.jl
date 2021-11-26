###############################################################################
#
# Determine Topt, Tmin, and Tmax 
#
# Input is MCD12C1 using IGBP majority land cover layer
#
# Output is one file for each year for each Topt, Tmin, and Tmax.
#
###############################################################################

function tparams(infile::String)

    LUToptT = Dict([(0 => 30), (1 => 20), (2 => 28), (3 => 20), (4 => 20), (5 => 19), (6 => 25), (7 => 31), (8 => 24), (9 => 30), (10 => 27), (11 => 20), (12 => 30), (13 => 27), (14 => 27), (15 => 20), (16 => 30)]);
    LUTminT = Dict([(0 => 0), (1 => -1), (2 => 2), (3 => -1), (4 => -1), (5 => -1), (6 => -1), (7 => 1), (8 => -1), (9 => 1), (10 => 0), (11 => 0), (12 => -1), (13 => -1), (14 => 0), (15 => 0), (16 => 0)]);
    LUTmaxT = Dict([(0 => 48), (1 => 40), (2 => 48), (3 => 40), (4 => 40), (5 => 48), (6 => 48), (7 => 48), (8 => 48), (9 => 48), (10 => 48), (11 => 48), (12 => 48), (13 => 48), (14 => 48), (15 => 40), (16 => 48)]);

    full_path = infile * "=gd?HDF4_EOS:EOS_GRID:\"" * infile * "\":MOD12C1:Majority_Land_Cover_Type_1";

    land = gmt("read -Tg " * full_path);

    optT_map = [LUToptT[value] for value in land];
    minT_map = [LUTminT[value] for value in land];
    maxT_map = [LUTmaxT[value] for value in land];

    println("Topt, Tmin, and Tmax have been mapped.")
    return optT_map, minT_map, maxT_map
end
