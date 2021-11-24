

###############################################################################
#
# Quality control for input SIF
#
# Good values are those where mean - standard error > 0
#
###############################################################################

using NCDatasets
using Statistics
include("../save/save_nc.jl")
#using Colors, Plots

sif_file    = "/mnt/g/TROPOMI/esa/gridded/1deg/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.1deg.CF80.nc";
output_nc   = "/mnt/g/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc";
year        = 2019;
var_sname   = "sif743_qc";
var_lname   = "SIF743 Quality Controlled";
unit        = "mW/m²/sr/nm";

function filter_sif(file)
    sif   = Dataset(file)["SIF_Corr_743"]
    n     = Dataset(file)["n"]
    std   = Dataset(file)["SIF_Corr_743_std"]

    # Rotate and reverse to correct lat/lon
    sif    = sif[:,:,32:77]; # 2019
    n      = n[:,:,32:77]; # 2019
    std    = std[:,:,32:77]; # 2019
    sif    = reverse(mapslices(rotl90, sif, dims = [1,2]), dims = 1);
    n      = reverse(mapslices(rotl90, n, dims = [1,2]), dims = 1);
    std    = reverse(mapslices(rotl90, std, dims = [1,2]), dims = 1);

    sif    = replace!(sif, missing => NaN)
    n      = replace!(n, missing => NaN)
    std    = replace!(std, missing => NaN)

    # Determine good values using sif - sem
    sem    = std ./ sqrt.(n)
    good   = sif .- sem
    good[good .<= 0.0] .= NaN;

    # Filter for good values
    for time in 1:size(sif)[3]       
        # Get mean for each gridcell in each day
        for row in 1:size(sif)[1] 
            for col in 1:size(sif)[2]
                if isnan(good[row, col, time])
                    sif[row, col, time] = NaN
                end
            end
        end
    end

    save_nc(sif, output_nc, year, var_sname, var_lname, unit)
end

filter_sif(sif_file)

# Take a look
# heatmap(n[:,:,23], bg = :white, color = :viridis)

# histogram(vec(test[:,:,23]))