
###############################################################################
#
# Save arrays to nc file
#
# Input data should already be in the correct orientation [y, x, z] aka
# [lat, lon, time]. 
#
# For some reason, the julia package outputs nc files as [z, x, y] format,
# so the end of this script forces [z, y, x] format using ncpdq
###############################################################################

using NCDatasets
using Dates

function save_nc(data, path, y, var_sname, var_lname, unit)
    
    # Create output nc
    ds = Dataset(path, "c")

    ds.attrib["title"]    = var_lname
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"

    latres = 180 / minimum(size(data))
    lonres = 360 / maximum(size(data))
    lat    = collect(-90.0 + (latres / 2.0) : latres : 90.0 - (latres / 2.0))
    lon    = collect(-180.0 + (lonres / 2.0) : lonres : 180.0 - (lonres / 2.0))

    # If 3-d array, create time dimension and dates
    if length(size(data)) == 3
        defDim(ds, "time", size(data)[3])
        days    = Vector{Dates.DateTime}(undef, 0)
        n_days  = Dates.daysinyear(y)
        by_days = ceil(n_days / size(data)[3])

        for i in 1:by_days:n_days
            if i == 1
                day  = Date(y, 1, 1)
                days = cat(days, day, dims = 1)
            else
                day  = Date(y, 1, 1) + Dates.Day(i - 1)
                days = cat(days, day, dims = 1)
            end
        end
        dsTime = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "days since 1970-01-01","long_name" => "Time (UTC), start of interval"])
    end

    defDim(ds, "lat", length(lat))
    defDim(ds, "lon", length(lon))

    dsLat = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    
    dsLat[:] = lat
    dsLon[:] = lon

    # Create NCDict, which are the subdatasets
    NCDict = Dict{String, NCDatasets.CFVariable}()

    if length(size(data)) == 3
        NCDict[var_sname] = defVar(ds, var_sname, Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => unit, "long_name" => var_lname])
        dsTime[:] = days
    else
        NCDict[var_sname] = defVar(ds, var_sname, Float32, ("lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => unit, "long_name" => var_lname])
    end

    # Write data to nc file
    if length(size(data)) == 3
        for t in 1:size(data)[3]
            NCDict[var_sname][t,:,:] = data[:,:,t]
        end
    else
        NCDict[var_sname][:,:] = data[:,:]
    end

    close(ds)

    # Ensure NC convention: [z, y, x]
    if length(size(data)) == 3
        run(`ncpdq -a time,lat,lon -O $path $path`)
    else
        run(`ncpdq -a lat,lon -O $path $path`)
    end

    println("Output saved to " * path)
end