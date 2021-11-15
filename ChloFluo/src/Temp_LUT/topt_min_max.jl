###############################################################################
#
# Determine Topt, Tmin, and Tmax 
#
# Input is MCD12C1 using IGBP majority land cover layer
# Source:
# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form
#
# Output is one file for each year for each Topt, Tmin, and Tmax.
#
###############################################################################

using GMT
using NCDatasets
using StatsBase
# using Colors, Plots

input_hdf  = "/mnt/g/ChloFluo/input/landcover/mcd12c1/MCD12C1.A2018001.006.2019200161458.hdf";
output_opt = "/mnt/g/ChloFluo/input/Temp/opt/5km/topt.5km.2018.nc";
output_min = "/mnt/g/ChloFluo/input/Temp/min/5km/tmin.5km.2018.nc";
output_max = "/mnt/g/ChloFluo/input/Temp/max/5km/tmax.5km.2018.nc";

LUToptT = Dict([(0 => 30), (1 => 20), (2 => 28), (3 => 20), (4 => 20), (5 => 19), (6 => 25), (7 => 31), (8 => 24), (9 => 30), (10 => 27), (11 => 20), (12 => 30), (13 => 27), (14 => 27), (15 => 20), (16 => 30)]);
LUTminT = Dict([(0 => 0), (1 => -1), (2 => 2), (3 => -1), (4 => -1), (5 => -1), (6 => -1), (7 => 1), (8 => -1), (9 => 1), (10 => 0), (11 => 0), (12 => -1), (13 => -1), (14 => 0), (15 => 0), (16 => 0)]);
LUTmaxT = Dict([(0 => 48), (1 => 40), (2 => 48), (3 => 40), (4 => 40), (5 => 48), (6 => 48), (7 => 48), (8 => 48), (9 => 48), (10 => 48), (11 => 48), (12 => 48), (13 => 48), (14 => 48), (15 => 40), (16 => 48)]);

full_path = input_hdf * "=gd?HDF4_EOS:EOS_GRID:\"" * input_hdf * "\":MOD12C1:Majority_Land_Cover_Type_1";

land = gmt("read -Tg " * full_path);

optT_map = [LUToptT[value] for value in land];
minT_map = [LUTminT[value] for value in land];
maxT_map = [LUTmaxT[value] for value in land];

    
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

    v = defVar(ds, sname, Float32, ("lat","lon"), deflatelevel = 4, fillvalue = -9999, attrib = ["units" => "C", "long_name" => lname])

    # Scale value does not work
    # v = defVar(ds, "LSWImax", Float32, ("lat","lon"), deflatelevel = 4, fillvalue = -9999, attrib = OrderedDict(
    #     "long_name"    => "LSWImax",
    #     "units"        => "Index",
    #     "scale_factor" => Float32(0.0001),
    #     "add_offset"   => Float32(0.0)))

    v[:,:] = data

    close(ds)
end

save_nc(optT_map, output_opt, "topt", "Optimum Temperature");
save_nc(minT_map, output_min, "tmin", "Minimum Temperature");
save_nc(maxT_map, output_max, "tmax", "Maximum Temperature");

# Take a look
# heatmap(maxT_map, bg = :white, color = :viridis)

