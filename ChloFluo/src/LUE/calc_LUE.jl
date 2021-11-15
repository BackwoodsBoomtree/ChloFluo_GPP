###############################################################################
#
# Determine LUEmax
#
# Input is MCD12C1 and ISLSCP II
#
# Output is one file for each year for each Topt, Tmin, and Tmax.
#
# Note: ISLSCP map saved to nc using qgis.
#       Might be improved in future for higher resolution using cropland maps,
#       i.e., VPM and Earth Stats
#
###############################################################################

# using GMT
using NCDatasets
using StatsBase
using Colors, Plots

# input_hdf  = "/mnt/g/ChloFluo/input/landcover/mcd12c1/MCD12C1.A2018001.006.2019200161458.hdf";
c4_map     = "/mnt/g/ChloFluo/input/C3C4/ISLSCP/c4_percent_1d.nc";
output_lue = "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc";

# Possible future use
# LUT_LUEe = Dict([(0 => NaN), (1 => 0.78), (2 => 0.78), (3 => 0.78), (4 => 0.78), (5 => 0.78), (6 => 0.78), (7 => 0.78), (8 => 0.78), (9 => 0.78), (10 => 0.78), (11 => 0.78), (12 => 0.78), (13 => 0.78), (14 => 0.78), (15 => 0.78), (16 => 0.78)]);
# full_path = input_hdf * "=gd?HDF4_EOS:EOS_GRID:\"" * input_hdf * "\":MOD12C1:Majority_Land_Cover_Type_1";
# land = gmt("read -Tg " * full_path);
# LUE_map = [LUT_LUEe[value] for value in land];

c4_perc = Dataset(c4_map)["Band1"][:,:]
c4_perc = rotr90(c4_perc)
c4_perc = reverse!(c4_perc, dims = 2)
c4_perc = replace!(c4_perc, missing => NaN)
c4_perc = c4_perc / 100

lue = (c4_perc .* 0.117) + ((1 .- c4_perc) .* 0.078)

function save_nc(data, path, sname, lname)
    
    ds = Dataset(path, "c")

    ds.attrib["title"]    = lname
    ds.attrib["comments"] = "Data computed for ChloFlo model."
    ds.attrib["author"]   = "Russell Doughty, PhD"
    ds.attrib["source"]   = "MCD12C1 and LUT"

    res = 180 / size(data)[1]
    lat = collect(-90.0 + (res / 2.0) : res : 90.0 - (res / 2.0))
    lon = collect(-180.0 + (res / 2.0) : res : 180.0 - (res / 2.0))

    defDim(ds,"lon", length(lon))
    defDim(ds,"lat", length(lat))

    dsLon    = defVar(ds, "lon" , Float32,("lon",), attrib = ["units" => "degrees_east", "long_name" => "Longitude"])
    dsLat    = defVar(ds, "lat" , Float32,("lat",), attrib = ["units" => "degrees_north", "long_name" => "Latitude"])
    dsLon[:] = lon
    dsLat[:] = lat

    v = defVar(ds, sname, Float32, ("lat","lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "-", "long_name" => lname])

    v[:,:] = data

    close(ds)
end

save_nc(lue, output_lue, "LUEmax", "Maximum Light Use Efficiency");

# Take a look
heatmap(lue, bg = :white, color = :viridis)

