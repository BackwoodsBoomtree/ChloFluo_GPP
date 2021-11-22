
###############################################################################
#
# Save arrays to nc file
#
# 
#
###############################################################################

using NCDatasets
using Dates

function save_nc(data, path, y, var_sname, var_lname, unit)
    
    # Arrange data for [x, y, z], which will later be input into nc as [z, x, y]
    # and finally permuted with ncpdq for proper [z, y, x] format
    if length(size(data)) == 3
        if size(data)[1] < size(data)[2]
            data = permutedims(data, [2,1,3])
            data = reverse(data, dims = 1)
        end
    else
        if size(data)[1] < size(data)[2]
            data = permutedims(data, [2,1])
            data = reverse(data, dims = 1)
        end
    end

    # Create output nc
    ds = Dataset(path, "c")

    ds.attrib["title"]    = var_lname
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"

    latres = 180 / size(data)[1]
    lonres = 360 / size(data)[2]
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
        NCDict[var_sname] = defVar(ds, var_sname, Float32, ("time", "lon", "lat"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => unit, "long_name" => var_lname])
        dsTime[:] = days
    else
        NCDict[var_sname] = defVar(ds, var_sname, Float32, ("lon", "lat"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => unit, "long_name" => var_lname])
    end

    # NC convention follows [z, y, x]
    if length(size(data)) == 3
        for t in 1:size(data)[3]
            NCDict[var_sname][t,:,:] = data[:,:,t]
        end
    else
        NCDict[var_sname][:,:] = data[:,:]
    end

    close(ds)

    run(`ncpdq -a time,lat,lon -O $path $path`)

    println("Output saved to " * path)
end