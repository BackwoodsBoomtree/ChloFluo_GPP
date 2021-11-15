###############################################################################
#
# Calculate Average Daytime Temperature for each year for Tscalar 
#
# Input are ERA5 temperature data, which are annual.
# Source:
# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form
#
# Output is one file for each year. Temps converted from K to C
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
using Dates
# using Colors, Plots

input_nc  = "/mnt/g/ChloFluo/input/Temp/era/Temp.ERA.2019.nc";
output_nc = "/mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2019.nc";

# Get max of timeseries
function calc_temp_day(infile::String)

    temp_data = Dataset(infile)["t2m"]

    # Calculates day time temp for each day
    temp_daytime = zeros(Float32, size(temp_data)[1], size(temp_data)[2], Int(size(temp_data)[3] / 24));
    doy = 0;
    for i in 1:24:size(temp_data)[3]
        doy = doy + 1
        println("Processing daily data for ", doy, " of ", Int(size(temp_data)[3] / 24))
        temp_in  = temp_data[:,:,i:(i+23)]
        temp_out = zeros(Float32, size(temp_in)[1], size(temp_in)[2])
        
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

function save_nc(infile::String, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "Mean Daytime Temperature for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "ERA5"

    latres = 180 / size(data)[1]
    lonres = 360 / size(data)[2]
    lat = collect(-90.0 + (latres / 2.0) : latres : 90.0 - (latres / 2.0))
    lon = collect(-180.0 + (lonres / 2.0) : lonres : 180.0 - (lonres / 2.0))

    defDim(ds, "time", size(data)[3])
    defDim(ds, "lat", length(lat))
    defDim(ds, "lon", length(lon))

    dsTime    = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "days since 1970-01-01","long_name" => "Time (UTC), start of interval"])
    dsLat     = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon     = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    
    # Build list of dates from original input date (hourly to 8-day)
    hours = Dataset(infile)["time"][:,:] # Get dates from lswi time series
    days  = Vector{Dates.DateTime}(undef, 0)
    days8 = Vector{Dates.DateTime}(undef, 0)
    for i in 1:24:length(hours)
        days = cat(days, hours[i], dims = 1)
    end
    for i in 1:8:length(days)
        days8 = cat(days8, days[i], dims = 1)
    end

    dsTime[:] = days8
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, "t2m_daytime", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "C", "long_name" => "Mean Daytime 2m Air Temperature"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

temp_out = calc_temp_day(input_nc)
save_nc(input_nc, temp_out, output_nc)

# Take a look
#heatmap(temp_out[:,:,23], bg = :white, color = :viridis)