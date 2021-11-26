

###############################################################################
#
# World's First SIF-based LUE GPP Model
#
# Badass
#
###############################################################################

function calc_gpp(apar, lue, stress)
    apar   = Dataset(apar)["aparchl"][:,:,:]
    lue    = Dataset(lue)["LUEmax"][:,:,:]
    stress = Dataset(stress)["stress"][:,:,:]

    # Arrange rasters dims to match
    apar   = reverse(mapslices(rotl90, apar, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    lue    = reverse(rotl90(lue), dims = 1)  # Rotate and reverse to correct lat/lon
    stress = reverse(mapslices(rotl90, stress, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    
    apar   = replace!(apar, missing => NaN)
    lue    = replace!(lue, missing => NaN)
    stress = replace!(stress, missing => NaN)


    gpp_stack = zeros(Float32, size(apar))
    for i in 1:size(apar)[3]
        println("Processing 8-day data for ", i, " of 46")
        gpp = apar[:,:,i] .* lue[:,:] .* stress[:,:,i]
        gpp_stack[:,:,i] = gpp
    end

    println("GPP has been computed. You are amazing!")
    return gpp_stack
end
