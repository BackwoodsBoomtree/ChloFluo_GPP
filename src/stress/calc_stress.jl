###############################################################################
#
# Calculate stress
#
# Inputs are Tscalar and Wscalar
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

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

stress = calc_stress(tfile, wfile)
save_nc(tfile, stress, output_nc);

# Take a look
heatmap(stress[:,:,23], bg = :white, color = :viridis)