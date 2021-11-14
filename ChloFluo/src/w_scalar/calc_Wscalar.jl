###############################################################################
#
# Calculate Wscalar 
#
# Input are the 8-day MCD43C4 LSWI nc files, which are annual, and LSWImax
# Codes for producting LSWI are here: https://github.com/GeoCarb-OU/MCD43C4_VIs
#
# Output is one file for each year.
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
# using Colors, Plots

lswi_nc    = "/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2018.LSWI.8-day.1deg.nc";
lswimax_nc = "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2018.nc";
output_nc  = "/mnt/g/ChloFluo/input/wscalar/1deg/LSWImax.8-day.1deg.2018.nc";

# Calc wscalar for teach time step and return 3d array
function calc_wscalar(lswi::String, lswi_max::String)
    
    dates = Dataset(lswi)["time"]
    dates = dates[:,:]
    
    lswi     = Dataset(lswi)["LSWI"]
    lswi_max = Dataset(lswi_max)["LSWImax"]
    lswi     = reverse(mapslices(rotl90, lswi, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    lswi_max = lswi_max[:,:]
    lswi     = Float32.(replace!(lswi, missing => NaN))
    lswi_max = Float32.(replace!(lswi_max, missing => NaN))

    wscalar_stack = zeros(Float32, size(lswi))
    for i in 1:size(lswi)[3]
        wscalar = (lswi[:,:,i] .+ 1.0) ./ (lswi_max[:,:] .+ 1.0)
        wscalar[wscalar .> 1.0] .= 1.0
        wscalar[wscalar .< 0.0] .= 0.0
        wscalar_stack[:,:,i]     = wscalar
    end

    return(wscalar_stack)
end


function save_nc(lswi, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "Water Scalar for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "MCD43C4"

    res = 180 / size(data)[1]
    lat = collect(-90.0 + (res / 2.0) : res : 90.0 - (res / 2.0))
    lon = collect(-180.0 + (res / 2.0) : res : 180.0 - (res / 2.0))

    defDim(ds, "time", size(data)[3])
    defDim(ds,"lat", length(lat))
    defDim(ds,"lon", length(lon))

    dsTime    = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "days since 1970-01-01","long_name" => "Time (UTC), start of interval"])
    dsLat     = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon     = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsTime[:] = Dataset(lswi)["time"][:,:] # Get dates from lswi time series
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, "wscalar", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Index", "long_name" => "Water Scalar"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

wscalar = calc_wscalar(lswi_nc, lswimax_nc)
save_nc(lswi_nc, wscalar, output_nc)

# Take a look
# heatmap(lswi[:,:,20], clim = (-0.5, 0.5), bg = :white, color = :viridis)
# heatmap(wscalar_stack[:,:,20], bg = :white, color = :viridis)