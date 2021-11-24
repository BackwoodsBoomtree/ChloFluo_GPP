
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################


function calc_apar(sif::String, yield::String)
    sif    = Dataset(sif)["sif743_qc"][:,:,:]
    yield  = Dataset(yield)["sif_yield"][:,:,:]

    # Arrange rasters dims to match
    sif    = replace!(sif, missing => NaN)
    yield  = replace!(yield, missing => NaN)

    apar             = sif ./ yield
    apar             = replace!(apar, missing => NaN)
    apar[apar .< 0] .= NaN;
    apar             = permutedims(apar, [2,1,3])

    println("APARchl has been calculated.")
    return(apar)
end