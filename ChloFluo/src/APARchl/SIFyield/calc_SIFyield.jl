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
using Dates
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

function save_nc(data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "SIF Yield for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "SIFyield = CLIMA APAR / CLIMA SIF"

    res = 180 / size(data)[1]
    lat = collect(-90.0 + (res / 2.0) : res : 90.0 - (res / 2.0))
    lon = collect(-180.0 + (res / 2.0) : res : 180.0 - (res / 2.0))

    defDim(ds, "time", size(data)[3])
    defDim(ds, "lat", length(lat))
    defDim(ds, "lon", length(lon))

    dsTime    = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "days since 1970-01-01","long_name" => "Time (UTC), start of interval"])
    dsLat     = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon     = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsLat[:]  = lat
    dsLon[:]  = lon

    # Create list of dates
    n_days = Dates.daysinyear(year)
    days8 = Vector{Dates.DateTime}(undef, 0)
    for i in 1:8:n_days
        if i == 1
            day = Date(year, 1, 1)
            days8 = cat(days8, day, dims = 1)
        else
            day = Date(year, 1, 1) + Dates.Day(i - 1)
            days8 = cat(days8, day, dims = 1)
        end
    end

    dsTime[:] = days8

    v = defVar(ds, "SIFyield", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Ratio of CLIMA APAR / CLIMA SIF", "long_name" => "SIFyield"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

yield = calc_yield(clima_file);

save_nc(yield, output_nc)

# Take a look
heatmap(yield[:,:,1], bg = :white, color = :viridis)
