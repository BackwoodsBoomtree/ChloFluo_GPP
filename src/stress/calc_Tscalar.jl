###############################################################################
#
# Calculate Tscalar
#
# Inputs are Topt, Tmin, Tmax, and T daytime
#
# Output is an nc file for each year that includes a layer for each timestep
#
###############################################################################

function calc_tscalar(tday, topt, tmin, tmax)

    tday = Dataset(tday)["t2m_daytime"][:,:,:]
    topt = Dataset(topt)["topt"][:,:]
    tmin = Dataset(tmin)["tmin"][:,:]
    tmax = Dataset(tmax)["tmax"][:,:]

    tday = reverse(mapslices(rotl90, tday, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    topt = reverse(rotl90(topt), dims = 1)

    tscalar_stack = zeros(Float32, size(tday))
    for i in 1:size(tday)[3]
        println("Processing 8-day data for ", i, " of 46")
        tscalar = ((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) ./ (((tday[:,:,i] .- tmax) .* (tday[:,:,i] .- tmin)) .- ((tday[:,:,i] .- topt) .* (tday[:,:,i] .- topt)))
        tscalar[tscalar .> 1.0] .= 1.0
        tscalar[tscalar .< 0.0] .= 0.0
        tscalar_stack[:,:,i]     = tscalar
    end

    println("Calculated tscalar.")
    return(tscalar_stack)
end