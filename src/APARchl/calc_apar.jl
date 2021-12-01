
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################


function calc_apar(sif::String, y::String)
    sif    = Dataset(sif)["sif743_qc"][:,:,:]
    y      = Dataset(y)["sif_yield"][:,:,:]

    # Arrange rasters dims to match
    sif    = replace!(sif, missing => NaN)
    y      = replace!(y, missing => NaN)

    apar                = sif ./ y
    apar                = replace!(apar, missing => NaN)
    apar[apar .< 0]    .= NaN;
    apar[apar .== Inf] .= NaN;
    apar                = permutedims(apar, [2,1,3])

    println("APARchl has been calculated.")
    return(apar)
end