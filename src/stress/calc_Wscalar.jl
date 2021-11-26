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
using Plots, Colors

function calc_wscalar(lswi::String, lswi_max::String)
       
    lswi     = Dataset(lswi)["LSWI"][:,:,:]
    lswi_max = Dataset(lswi_max)["LSWImax"][:,:]
    lswi     = reverse(mapslices(rotl90, lswi, dims = [1,2]), dims = 1)  # Rotate and reverse to correct lat/lon
    lswi_max = reverse(rotl90(lswi_max), dims = 1)                       # Rotate and reverse to correct lat/lon
    lswi     = Float32.(replace!(lswi, missing => NaN))
    lswi_max = Float32.(replace!(lswi_max, missing => NaN))

    wscalar_stack = zeros(Float32, size(lswi))
    for i in 1:size(lswi)[3]
        println("Processing 8-day data for ", i, " of 46")
        wscalar = (lswi[:,:,i] .+ 1.0) ./ (lswi_max[:,:] .+ 1.0)
        wscalar[wscalar .> 1.0] .= 1.0
        wscalar[wscalar .< 0.0] .= 0.0
        wscalar_stack[:,:,i]     = wscalar
    end

    println("Water Scalar has been calculated.")
    return(wscalar_stack)
end