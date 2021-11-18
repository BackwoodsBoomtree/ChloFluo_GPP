
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
using Dates
# using Colors, Plots

sif_file    = "/mnt/g/TROPOMI/esa/gridded/1deg/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.1deg.CF80.nc";
yield_file  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc";

function calc_apar(sif, yield)
    sif    = Dataset(sif)["SIF_Corr_743"]
    yield  = Dataset(yield)["SIFyield"]

    # Arrange rasters dims to match
    sif    = sif[:,:,32:77]; # 2019
    sif    = reverse(mapslices(rotl90, sif, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon
    yield  = permutedims(yield, [2,3,1])
    yield  = replace!(yield, missing => NaN)

    apar             = sif ./ yield;
    apar             = replace!(apar, missing => NaN);
    apar[apar .< 0] .= NaN;

    return(apar)
end

function save_nc(infile, data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "APAR Chlorophyll"
    ds.attrib["comments"] = "Produced for ChloFluo"
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
    dsTime[:] = Dataset(infile)["time"][:,:] # Get dates from input file
    dsLat[:]  = lat
    dsLon[:]  = lon

    v = defVar(ds, "aparchl", Float32, ("time", "lat", "lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "μmol/m-2/day-1", "long_name" => "APARchl"])

    # NC convention follows [z, y, x]
    for t in 1:size(data)[3]
         v[t,:,:] = data[:,:,t]
    end

    close(ds)
end

apar = calc_apar(sif_file, yield_file);
save_nc(yield_file, apar, output_nc)