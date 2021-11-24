

###############################################################################
#
# Quality control for input SIF
#
# Good values are those where mean - standard error > 0
#
###############################################################################

function sif_qc(file::String, key::String, n::String, key_std::String, first::Int, last::Int)
    data  = Dataset(file)[key][:,:,first:last]
    num   = Dataset(file)[n][:,:,first:last]
    std   = Dataset(file)[key_std][:,:,first:last]

    # Rotate and reverse to correct lat/lon
    data  = reverse(mapslices(rotl90, data, dims = [1,2]), dims = 1);
    num   = reverse(mapslices(rotl90, num,  dims = [1,2]), dims = 1);
    std   = reverse(mapslices(rotl90, std,  dims = [1,2]), dims = 1);

    data  = replace!(data, missing => NaN)
    num   = replace!(num,  missing => NaN)
    std   = replace!(std,  missing => NaN)

    # Determine good values using sif - sem
    sem                 = std ./ sqrt.(num)
    good                = data .- sem
    good[good .<= 0.0] .= NaN;

    # Filter for good values
    for time in 1:size(data)[3]       
        # Get mean for each gridcell in each day
        for row in 1:size(data)[1] 
            for col in 1:size(data)[2]
                if isnan(good[row, col, time])
                    data[row, col, time] = NaN
                end
            end
        end
    end

    println(key * " has been QCed using " * n * " and " * key_std * ". Good values are those where mean - standard error > 0")
    return(data)
end