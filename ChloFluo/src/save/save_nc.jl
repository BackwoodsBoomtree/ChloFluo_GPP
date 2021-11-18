
###############################################################################
#
# Save arrays to nc file
#
# 
#
###############################################################################

using NCDatasets
using Dates

function save_nc(data, path, year, var_sname, var_lname, unit)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = var_lname
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"

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
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, var_sname, Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => unit, "long_name" => var_lname])

    # Create list of dates
    if length(size(data)) == 3
        n_days  = Dates.daysinyear(year)
        by_days = ceil(n_days / size(data)[3])
        days = Vector{Dates.DateTime}(undef, 0)

        for i in 1:by_days:n_days
            if i == 1
                day  = Date(year, 1, 1)
                days = cat(days, day, dims = 1)
            else
                day  = Date(year, 1, 1) + Dates.Day(i - 1)
                days = cat(days, day, dims = 1)
            end
        end
    else
        days = Date(year, 1, 1)
    end

    dsTime[:] = days

    # NC convention follows [z, y, x]
    if length(size(data)) == 3
        for t in 1:size(data)[3]
            v[t,:,:] = data[:,:,t]
        end
    else
        v[:,:] = data
    end

    close(ds)
end