
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################

using NCDatasets
using Statistics
include("../save/save_nc.jl")
# using Colors, Plots

sif_file    = "/mnt/g/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc";
yield_file  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc";
year        = 2019;
var_sname   = "aparchl";
var_lname   = "APARchl";
unit        = "μmol/m⁻²/day⁻¹";

function calc_apar(sif, yield)
    sif    = Dataset(sif)["sif743_qc"]
    yield  = Dataset(yield)["SIFyield"]

    # Arrange rasters dims to match
    sif    = permutedims(sif, [2,3,1])
    sif    = replace!(sif, missing => NaN)
    yield  = permutedims(yield, [2,3,1])
    yield  = replace!(yield, missing => NaN)

    apar             = sif ./ yield;
    apar             = replace!(apar, missing => NaN);
    apar[apar .< 0] .= NaN;

    save_nc(apar, output_nc, year, var_sname, var_lname, unit)
end

calc_apar(sif_file, yield_file);