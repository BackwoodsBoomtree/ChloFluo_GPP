###############################################################################
#
# Calculate SIFyield
#
# Input are CLIMA simulations
#
# Output is one file for each year.
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
include("save/save_nc.jl")
using Colors, Plots

clima_file = "/mnt/g/CLIMA/clima_land_2019_1X_1H.hs.nc";
year       = 2019
output_nc  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";

function calc_yield(infile)
    sif  = Dataset(infile)["SIF740"][:,:,:];
    apar = Dataset(infile)["APAR"][:,:,:];

    apar  = apar .* 1000000; # umol/m2/s1
    yield = sif ./ apar;

    # Calculates yield for each day
    yield_daily = zeros(Float32, size(yield)[1], size(yield)[2], Int(size(yield)[3] / 24));
    doy = 0;

    for i in 1:24:size(yield)[3]
        doy = doy + 1
        println("Processing daily data for ", doy, " of ", Int(size(yield)[3] / 24))
        yield_in  = yield[:,:,i:(i+23)]
        yield_out = zeros(Float32, size(yield_in)[1], size(yield_in)[2])
        
        # Get mean for each gridcell in each day
        for row in 1:size(yield_in)[1] 
            for col in 1:size(yield_in)[2]
                vals = zeros(0)
                for time in 1:24
                    val = yield_in[row, col, time]
                    if !isnan(val)
                        append!(vals, val)
                    end
                end
                if length(vals) != 0
                    mean_val = mean(vals)
                else
                    mean_val = NaN
                end
                yield_out[row, col] = Float32.(mean_val)
            end
        end
        yield_daily[:,:,doy] = yield_out
    end

    # Aggregate to 8-day (works for nonleap and leap years)
    yield_8day = zeros(Float32, size(yield_daily)[1], size(yield_daily)[2], 46);
    doy = 0;
    for i in 1:8:size(yield_daily)[3]
        doy = doy + 1
        println("Processing 8-day data for ", doy, " of 46")

        # Last day is 5 or 6 days
        if doy != 46
            yield_in = yield_daily[:,:,i:(i+7)]
        else
            yield_in = yield_daily[:,:,i:size(yield_daily)[3]]
        end

        yield_out = zeros(Float32, size(yield_in)[1], size(yield_in)[2])

        for row in 1:size(yield_in)[1] 
            for col in 1:size(yield_in)[2]
                vals = zeros(0)
                for time in 1:size(yield_in)[3]
                    val = yield_in[row, col, time]
                    if !isnan(val)
                        append!(vals, val)
                    end
                end
                if length(vals) != 0
                    mean_val = mean(vals)
                else
                    mean_val = NaN
                end
                yield_out[row, col] = Float32.(mean_val)
            end
        end
        yield_8day[:,:,doy] = yield_out
    end

    yield_8day = reverse(mapslices(rotl90, yield_8day, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon

    return(yield_8day)
end

yield = calc_yield(clima_file);

save_nc(yield, output_nc)

# Take a look
heatmap(yield[:,:,1], bg = :white, color = :viridis)
