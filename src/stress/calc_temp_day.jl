###############################################################################
#
# Calculate Average Daytime Temperature for Tscalar 
#
# Input are ERA5 2m air temperature data, which are hourly.
# Source:
# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form
#
# Output is one file for each year with temps converted from K to C.
#
###############################################################################


# Get mean daytime temperature for each day from hourly data 
function calc_temp_day(infile::String)

    temp_data = Dataset(infile)["t2m"]

    # Calculates daytime temp for each day
    temp_daytime = zeros(Float32, size(temp_data)[1], size(temp_data)[2], Int(size(temp_data)[3] / 24));
    doy = 0;

    for i in 1:24:size(temp_data)[3]
        doy = doy + 1
        println("Processing daily data for ", doy, " of ", Int(size(temp_data)[3] / 24))
        temp_in  = temp_data[:,:,i:(i+23)]
        temp_out = zeros(Float32, size(temp_in)[1], size(temp_in)[2])
        
        # Get min and max values for each gridcell in each day
        for row in 1:size(temp_in)[1] 
            for col in 1:size(temp_in)[2]
                vals = zeros(0)
                for time in 1:24
                    val = temp_in[row, col, time]
                    append!(vals, val)
                end
                max_val = maximum(vals)
                min_val = minimum(vals)
                temp    = (0.75 * max_val) + (0.25 * min_val)
                temp_out[row, col] = Float32.(temp)
            end
        end
        temp_daytime[:,:,doy] = temp_out
    end

    # Aggregate to 8-day (works for nonleap and leap years)
    temp_8day = zeros(Float32, size(temp_daytime)[1], size(temp_daytime)[2], 46);
    doy = 0;
    for i in 1:8:size(temp_daytime)[3]
        doy = doy + 1
        println("Processing 8-day data for ", doy, " of 46")

        # Last day is 5 or 6 days
        if doy != 46
            temp_in = temp_daytime[:,:,i:(i+7)]
        else
            temp_in = temp_daytime[:,:,i:size(temp_daytime)[3]]
        end

        temp_out = zeros(Float32, size(temp_in)[1], size(temp_in)[2])

        for row in 1:size(temp_in)[1] 
            for col in 1:size(temp_in)[2]
                vals = zeros(0)
                for time in 1:size(temp_in)[3]
                    val = temp_in[row, col, time]
                    append!(vals, val)
                end
                meanval = mean(vals)
                temp_out[row, col] = Float32.(meanval)
            end
        end
        temp_8day[:,:,doy] = temp_out
    end

    # Convert to C
    temp_8day = temp_8day .- Float32(273.15)
    temp_8day = mapslices(rotl90, temp_8day, dims = [1,2])

    return(temp_8day)
end