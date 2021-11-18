
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
include("save/save_nc.jl")
# using Colors, Plots

sif_file    = "/mnt/g/TROPOMI/esa/gridded/1deg/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.1deg.CF80.nc";
yield_file  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc";

function calc_apar(sif, yield)
    sif    = Dataset(sif)["SIF_Corr_743"]
    yield  = Dataset(yield)["SIFyield"]

    # Arrange rasters dims to match
    sif    = sif[:,:,32:77]; # 2019
    sif    = reverse(mapslices(rotl90, sif, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon
    yield  = permutedims(yield, [2,3,1])
    yield  = replace!(yield, missing => NaN)

    apar             = sif ./ yield;
    apar             = replace!(apar, missing => NaN);
    apar[apar .< 0] .= NaN;

    return(apar)
end

apar = calc_apar(sif_file, yield_file);
save_nc(yield_file, apar, output_nc)