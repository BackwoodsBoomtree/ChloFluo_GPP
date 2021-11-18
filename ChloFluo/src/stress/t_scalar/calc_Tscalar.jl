###############################################################################
#
# Calculate Tscalar
#
# Inputs are Topt, Tmin, Tmax, and T daytime
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
# using Colors, Plots

tday_file = "/mnt/g/ChloFluo/input/Temp/daytime/1deg/8day/Temp.mean.daytime.8day.era.1deg.2020.nc";
topt_file = "/mnt/g/ChloFluo/input/Temp/opt/1deg/topt.1deg.2019.nc";
tmin_file = "/mnt/g/ChloFluo/input/Temp/min/1deg/tmin.1deg.2019.nc";
tmax_file = "/mnt/g/ChloFluo/input/Temp/max/1deg/tmax.1deg.2019.nc";
output_nc = "/mnt/g/ChloFluo/input/tscalar/1deg/tscalar.8-day.1deg.2020.nc";

# Calc wscalar for teach time step and return 3d array
function calc_tscalar(tday, topt, tmin, tmax)

    tday = Dataset(tday)["t2m_daytime"]
    topt = Dataset(topt)["topt"]
    tmin = Dataset(tmin)["tmin"]
    tmax = Dataset(tmax)["tmax"]

    tday = reverse(mapslices(rotl90, tday, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    
    tscalar_stack = zeros(Float32, size(tday))
    for i in 1:size(tday)[3]
        println("Processing 8-day data for ", i, " of 46")
        tscalar = ((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) ./ (((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) .- ((tday[:,:,i] .- topt) .* (tday[:,:,i] .- topt)))
        tscalar[tscalar .> 1.0] .= 1.0
        tscalar[tscalar .< 0.0] .= 0.0
        tscalar_stack[:,:,i]     = tscalar
    end

    return(tscalar_stack)
end

function save_nc(infile, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "Temperature Scalar for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "ERA5"

    res = 180 / size(data)[1]
    lat = collect(-90.0 + (res / 2.0) : res : 90.0 - (res / 2.0))
    lon = collect(-180.0 + (res / 2.0) : res : 180.0 - (res / 2.0))

    defDim(ds, "time", size(data)[3])
    defDim(ds, "lat", length(lat))
    defDim(ds, "lon", length(lon))

    dsTime    = defVar(ds, "time" ,Float32,("time",), attrib = ["units" => "days since 1970-01-01","long_name" => "Time (UTC), start of interval"])
    dsLat     = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon     = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsTime[:] = Dataset(infile)["time"][:,:] # Get dates from lswi time series
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, "tscalar", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Index", "long_name" => "Temperature Scalar"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

tscalar = calc_tscalar(tday_file, topt_file, tmin_file, tmax_file)
save_nc(tday_file, tscalar, output_nc);

# Take a look
# heatmap(tscalar[:,:,23], bg = :white, color = :viridis)