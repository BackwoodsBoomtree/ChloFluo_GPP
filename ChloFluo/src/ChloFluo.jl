

###############################################################################
#
# World's First SIF-based LUE GPP Model
#
# Badass
#
###############################################################################

using NCDatasets
using Statistics
# using Colors, Plots
include("save/save_nc.jl")

apar_file   = "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc";
stress_file = "/mnt/g/ChloFluo/input/stress/1deg/stress.8-day.1deg.2019.nc";
lue_file    = "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc";
land_file   = "/mnt/g/ChloFluo/input/landcover/MCD12C1.A2019.majority.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc";
y           = 2019;
var_sname   = "gpp";
var_lname   = "Gross Primary Production";
unit        = "g C/m⁻²/day⁻¹";

function calc_gpp(apar, stress, lue, land)
    apar   = Dataset(apar)["aparchl"]
    stress = Dataset(stress)["stress"]
    lue    = Dataset(lue)["LUEmax"]
    land   = Dataset(land_file)["Band1"]

    # Arrange rasters dims to match
    apar   = permutedims(apar, [2,3,1])
    apar   = replace!(apar, missing => NaN)
    stress = permutedims(stress, [2,3,1])
    stress = replace!(stress, missing => NaN)
    lue    = lue[:,:,:]
    lue    = replace!(lue, missing => NaN)
    land   = permutedims(land, [2,1])

    gpp_stack = zeros(Float32, size(apar))
    for i in 1:size(apar)[3]
        println("Processing 8-day data for ", i, " of 46")
        gpp = apar[:,:,i] .* lue[:,:] .* stress[:,:,i]
        gpp_stack[:,:,i] = gpp
    end

    # Set water to NaN
    for time in 1:size(gpp_stack)[3]       
        # Get mean for each gridcell in each day
        for row in 1:size(gpp_stack)[1] 
            for col in 1:size(gpp_stack)[2]
                if land[row, col] == 0
                    gpp_stack[row, col, time] = NaN
                end
            end
        end
    end

    save_nc(gpp_stack, output_nc, y, var_sname, var_lname, unit)
end

calc_gpp(apar_file, stress_file, lue_file, land_file);

# Take a look
# heatmap(lue[:,:,23], bg = :white, color = :viridis)