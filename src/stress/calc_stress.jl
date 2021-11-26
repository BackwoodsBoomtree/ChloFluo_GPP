###############################################################################
#
# Calculate stress
#
# Inputs are Tscalar and Wscalar
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

function calc_stress(tscalar, wscalar)

    tscalar = Dataset(tscalar)["tscalar"][:,:,:]
    wscalar = Dataset(wscalar)["wscalar"][:,:,:]

    # Need to permute because they are imported in [z,y,x] format from nc
    tscalar = reverse(mapslices(rotl90, tscalar, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    wscalar = reverse(mapslices(rotl90, wscalar, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon

    stress_stack = zeros(Float32, size(tscalar))
    for i in 1:size(tscalar)[3]
        println("Processing 8-day data for ", i, " of 46")
        stress = tscalar[:,:,i] .* wscalar[:,:,i]
        stress[stress .> 1.0] .= 1.0
        stress[stress .< 0.0] .= 0.0
        stress_stack[:,:,i]    = stress
    end
  
    println("Stress calculated.")
    return(stress_stack)
end