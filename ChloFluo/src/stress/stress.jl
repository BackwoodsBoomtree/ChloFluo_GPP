###############################################################################
#
# Calculate stress
#
# Inputs are Tscalar and Wscalar
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
using Colors, Plots

tfile     = "/mnt/g/ChloFluo/input/tscalar/1deg/tscalar.8-day.1deg.2020.nc";
wfile     = "/mnt/g/ChloFluo/input/wscalar/1deg/wscalar.8-day.1deg.2020.nc";
output_nc = "/mnt/g/ChloFluo/input/stress/1deg/stress.8-day.1deg.2020.nc";

# Calc wscalar for teach time step and return 3d array
function calc_stress(tscalar, wscalar)

    tscalar = Dataset(tscalar)["tscalar"]
    wscalar = Dataset(wscalar)["wscalar"]

    # Need to permute because they are imported in [z,y,x] format from nc
    tscalar = permutedims(tscalar, [2,3,1])
    wscalar = permutedims(wscalar, [2,3,1])

    stress_stack = zeros(Float32, size(tscalar))
    for i in 1:size(tscalar)[3]
        println("Processing 8-day data for ", i, " of 46")
        stress = tscalar[:,:,i] .* wscalar[:,:,i]
        stress[stress .> 1.0] .= 1.0
        stress[stress .< 0.0] .= 0.0
        stress_stack[:,:,i]    = stress
    end
  
    return(stress_stack)
end

function save_nc(infile, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "Stress Scalar for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "tscalar * wscalar"

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

    v = defVar(ds, "stress", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Index", "long_name" => "Stress"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

stress = calc_stress(tfile, wfile)
save_nc(tfile, stress, output_nc);

# Take a look
heatmap(stress[:,:,23], bg = :white, color = :viridis)