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
# using Colors, Plots

clima_file = "/mnt/g/CLIMA/clima_land_2019_1X_1H.hs.nc"
output_nc  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.hourly.nc"

sif  = Dataset(clima_file)["SIF740"];
apar = Dataset(clima_file)["APAR"];

apar  = apar .* 1000000; # umol/m2/s1
yield = sif ./ apar;

yield = reverse(mapslices(rotl90, yield, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon
# sif   = reverse(mapslices(rotl90, sif, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon
# apar  = reverse(mapslices(rotl90, apar, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon

# maximum(filter(!isnan,yield[:,:,18]))

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

    dsTime    = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "hours since 2019-01-01","long_name" => "Time (UTC), start of interval"])
    dsLat     = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon     = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsTime[:] = collect(0:(size(data)[3] - 1))
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, "SIFyield", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Ratio", "long_name" => "SIFyield"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

save_nc(yield, output_nc)

# Take a look
# heatmap(apar[:,:,18], bg = :white, color = :viridis)
# heatmap(sif[:,:,18], bg = :white, color = :viridis)
# heatmap(yield[:,:,18], bg = :white, color = :viridis)
# heatmap(apar[:,:,18], bg = :white, color = :viridis)