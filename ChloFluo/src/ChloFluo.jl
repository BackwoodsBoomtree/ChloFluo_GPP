

###############################################################################
#
# World's First SIF-based LUE GPP Model
#
# Badass
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
using Dates
# using Colors, Plots

apar_file  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";
stress_file = "/mnt/g/ChloFluo/input/stress/1deg/stress.8-day.1deg.2019.nc";
lue_file    = "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc";

function calc_gpp(apar, stress, lue)
    apar   = Dataset(apar)["aparchl"]
    stress = Dataset(stress)["stress"]
    lue    = Dataset(lue)["LUEmax"]

    # Arrange rasters dims to match
    apar   = permutedims(apar, [2,3,1])
    apar   = replace!(apar, missing => NaN)
    stress = permutedims(stress, [2,3,1])
    stress = replace!(stress, missing => NaN)
    lue    = lue[:,:,:]
    lue    = replace!(lue, missing => NaN)

    gpp_stack = zeros(Float32, size(apar))
    for i in 1:size(apar)[3]
        println("Processing 8-day data for ", i, " of 46")
        gpp = apar[:,:,i] .* lue[:,:] .* stress[:,:,i]
        gpp_stack[:,:,i] = gpp
    end
    return(gpp_stack)
end

function save_nc(infile, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "ChloFluo GPP"
    ds.attrib["comments"] = "SIF-based, Data-driven GPP"
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "University of Oklahoma"

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

    v = defVar(ds, "gpp", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "gC/m-2/day-1", "long_name" => "Gross Primary Production"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

gpp = calc_gpp(apar_file, stress_file, lue_file);
save_nc(apar_file, gpp, output_nc)

# Take a look
heatmap(lue[:,:,23], bg = :white, color = :viridis)