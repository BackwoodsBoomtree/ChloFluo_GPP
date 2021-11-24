###############################################################################
#
# Calculate Tscalar
#
# Inputs are Topt, Tmin, Tmax, and T daytime
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
include("../../save/save_nc.jl")
# using Colors, Plots

tday_file = "/mnt/g/ChloFluo/input/Temp/daytime/1deg/8day/Temp.mean.daytime.8day.era.1deg.2020.nc";
topt_file = "/mnt/g/ChloFluo/input/Temp/opt/1deg/topt.1deg.2019.nc";
tmin_file = "/mnt/g/ChloFluo/input/Temp/min/1deg/tmin.1deg.2019.nc";
tmax_file = "/mnt/g/ChloFluo/input/Temp/max/1deg/tmax.1deg.2019.nc";
output_nc = "/mnt/g/ChloFluo/input/tscalar/1deg/tscalar.8-day.1deg.2020.nc";

# Calc wscalar for teach time step and return 3d array
function calc_tscalar(tday, topt, tmin, tmax)

    tday = Dataset(tday)["t2m_daytime"]
    topt = Dataset(topt)["topt"]
    tmin = Dataset(tmin)["tmin"]
    tmax = Dataset(tmax)["tmax"]

    tday = reverse(mapslices(rotl90, tday, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    
    tscalar_stack = zeros(Float32, size(tday))
    for i in 1:size(tday)[3]
        println("Processing 8-day data for ", i, " of 46")
        tscalar = ((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) ./ (((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) .- ((tday[:,:,i] .- topt) .* (tday[:,:,i] .- topt)))
        tscalar[tscalar .> 1.0] .= 1.0
        tscalar[tscalar .< 0.0] .= 0.0
        tscalar_stack[:,:,i]     = tscalar
    end

    return(tscalar_stack)
end

tscalar = calc_tscalar(tday_file, topt_file, tmin_file, tmax_file)
save_nc(tday_file, tscalar, output_nc);

# Take a look
# heatmap(tscalar[:,:,23], bg = :white, color = :viridis)