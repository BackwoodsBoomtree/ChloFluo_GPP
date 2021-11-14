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
using Colors, Plots

lswi_nc    = "/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2020.LSWI.8-day.1deg.nc";
lswimax_nc = "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2020.nc";
output_nc  = "/mnt/g/ChloFluo/input/w_scalar/1deg/LSWImax.8-day.1deg.2020.nc";


Wscalar =(10000+LSWI)*1.000/(10000+LSWImax)    # if lswi > 0, use the original function
#WscalarCROP=numpy.where(LSWI<=0,LSWI+LSWImax,Wscalar) # if lswi<=0, adjust the wscalar using lswi+lswimax
Wscalar=numpy.where(Wscalar>1,1,Wscalar)
Wscalar=numpy.where(Wscalar<0,0,Wscalar)

# Get maximum lswi
function calc_wscalar(lswi::String, lswi_max::String)
    lswi     = Dataset(lswi_nc)["LSWI"]
    lswi_max = Dataset(lswimax_nc)["LSWImax"]
    lswi     = reverse(mapslices(rotl90, lswi, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    lswi_max = lswi_max[:,:]
    lswi     = Float32.(replace!(lswi, missing => NaN))
    lswi_max = Float32.(replace!(lswi_max, missing => NaN))

    wscalar = (lswi[:,:,1] .+ 1.0) ./ (lswi_max[:,:] .+ 1.0)
    wscalar[wscalar .> 1.0] .= 1.0
    wscalar[wscalar .< 0.0] .= 0.0





    return data
end


function save_nc(data, path)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = "Water Scalar for ChloFluo"
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "MCD43C4"

    res = 180 / size(data)[1]
    lat = collect(-90.0 + (res / 2.0) : res : 90.0 - (res / 2.0))
    lon = collect(-180.0 + (res / 2.0) : res : 180.0 - (res / 2.0))

    defDim(ds,"lon", length(lon))
    defDim(ds,"lat", length(lat))

    dsLon    = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsLat    = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon[:] = lon
    dsLat[:] = lat

    v = defVar(ds, "LSWImax", Float32, ("lat","lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "Index", "long_name" => "LSWImax"])

    # Scale value does not work
    # v = defVar(ds, "LSWImax", Float32, ("lat","lon"), deflatelevel = 4, fillvalue = -9999, attrib = OrderedDict(
    #     "long_name"    => "LSWImax",
    #     "units"        => "Index",
    #     "scale_factor" => Float32(0.0001),
    #     "add_offset"   => Float32(0.0)))

    v[:,:] = data

    close(ds)
end


# Take a look
heatmap(lswi[:,:,20], clim = (-0.5, 0.5), bg = :white, color = :viridis)
heatmap(wscalar, bg = :white, color = :viridis)