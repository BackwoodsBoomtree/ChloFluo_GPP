###############################################################################
#
# Calculate Wscalar 
#
# Input are the 8-day MCD43C4 LSWI nc files, which are annual, and LSWImax
# Codes for producting LSWI are here: https://github.com/GeoCarb-OU/MCD43C4_VIs
#
# Output is one file for each year.
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
include("save/save_nc.jl")
# using Colors, Plots

lswi_nc    = "/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2018.LSWI.8-day.1deg.nc";
lswimax_nc = "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2018.nc";
output_nc  = "/mnt/g/ChloFluo/input/wscalar/1deg/wscalar.8-day.1deg.2018.nc";

# Calc wscalar for teach time step and return 3d array
function calc_wscalar(lswi::String, lswi_max::String)
       
    lswi     = Dataset(lswi)["LSWI"]
    lswi_max = Dataset(lswi_max)["LSWImax"]
    lswi     = reverse(mapslices(rotl90, lswi, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    lswi_max = lswi_max[:,:]
    lswi     = Float32.(replace!(lswi, missing => NaN))
    lswi_max = Float32.(replace!(lswi_max, missing => NaN))

    wscalar_stack = zeros(Float32, size(lswi))
    for i in 1:size(lswi)[3]
        println("Processing 8-day data for ", i, " of 46")
        wscalar = (lswi[:,:,i] .+ 1.0) ./ (lswi_max[:,:] .+ 1.0)
        wscalar[wscalar .> 1.0] .= 1.0
        wscalar[wscalar .< 0.0] .= 0.0
        wscalar_stack[:,:,i]     = wscalar
    end

    return(wscalar_stack)
end

wscalar = calc_wscalar(lswi_nc, lswimax_nc)
save_nc(lswi_nc, wscalar, output_nc)

# Take a look
# heatmap(lswi[:,:,20], clim = (-0.5, 0.5), bg = :white, color = :viridis)
# heatmap(wscalar_stack[:,:,20], bg = :white, color = :viridis)