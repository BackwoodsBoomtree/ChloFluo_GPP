###############################################################################
#
# Calculate Maximum LSWI for each year for Wscalar 
#
# Input are the 8-day 0.05-degree MCD43C4 LSWI nc files, which are annual.
# Codes for producting LSWI are here: https://github.com/GeoCarb-OU/MCD43C4_VIs
#
# Output is one file for each year.
#
###############################################################################

using NCDatasets
using DataStructures
using Statistics
using Colors, Plots

input_nc  = "/mnt/g/MCD43C4/nc/8-day/0.05/LSWI/MCD43C4.A.2018.LSWI.8-day.0.05.nc";
output_nc = "/mnt/g/ChloFlo/input/LSWImax/5km/LSWImax.8-day.5km.2018.nc";

# Get maximum lswi
function max_lswi(file::String)
    lswi = Dataset(file)["LSWI"]
    data = lswi[:,:]
    data = max_time(data)
    return data
end

# Check if all values in array are missing
function all_miss(values::Array{})
    for i in values
        if ismissing(i) == false
            return(false)
            break
        end
    end
    return(true)
end

# Get max of timeseries
function max_time(ts_data)
    amax = zeros(size(ts_data)[1], size(ts_data)[2])

    for row in 1:size(ts_data)[1] 
        for col in 1:size(ts_data)[2]
            vals = zeros(0)
            for time in 1:size(ts_data)[3]
                val = ts_data[row, col, time]
                if ismissing(val) == false
                    append!(vals, val)
                end
            end
            if length(vals) != 0    
                m_val          = maximum(vals)
                amax[row, col] = m_val
            else
                amax[row, col] = NaN
            end
        end
    end
    return(amax)
end

function save_nc(data, path)
    ds = Dataset(path, "c")

    defDim(ds,"lon", size(ts_data)[2])
    defDim(ds,"lat", size(ts_data)[1])

    ds.attrib["title"] = "Maximum LSWI"

    v = defVar(ds, "LSWImax", Float32,("lon","lat"), attrib = OrderedDict("units" => ""))
    v.attrib["comments"] = "Data computed for ChloFlo model."
    v.attrib["author"]   = "Russell Doughty, PhD"
    v.attrib["source"]   = "MCD43C4"

    v[:,:] = data

    close(ds)
end

data = max_lswi(input_nc);

# Take a look
plot_data = replace(data, missing => NaN);
heatmap(plot_data[:,:,1], clim = (-0.5, 0.5), bg = :white, color = :viridis)

save_nc(data, output_nc)
