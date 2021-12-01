###############################################################################
#
# Calculate SIFyield
#
# Input are CLIMA simulations
#
# Output is one file for each year.
#
###############################################################################


function calc_yield(infile)
    sif  = Dataset(infile)["SIF740"][:,:,:];
    apar = Dataset(infile)["APAR"][:,:,:];

    # We need to 'correct' the values at 1 degree to match the gridded TROPOMI SIF values
    # The CLIMA run assumes 0 SIF for non-land and non-veg, but the gridded SIF data 
    # treats area with no SIF to be NaN
    println("Adjusting SIF values for area.")
    zoom = 1; # spatial resolution is 1/zoom degree
    pft_cover   = load_LUT(PFTPercentCLM{Float32}(), zoom);
    land_cover  = load_LUT(LandMaskERA5{Float32}(), zoom, nan_weight = true);
    corr_factor = min.(land_cover.data[:,:,1], 1 .- pft_cover.data[:,:,1] ./ 100);

    sif = sif ./ corr_factor
    apar  = apar .* 1000000; # umol/m2/s1
    yield = sif ./ apar;

    # Calculate daily values (APAR units is per second, so need all values including 0)
    sif_daily   = zeros(Float32, size(sif)[1], size(sif)[2], Int(size(sif)[3] / 24));
    apar_daily  = zeros(Float32, size(sif)[1], size(sif)[2], Int(size(sif)[3] / 24));
    yield_daily = zeros(Float32, size(sif)[1], size(sif)[2], Int(size(sif)[3] / 24));
    doy = 0;

    for i in 1:24:size(yield)[3]
        doy = doy + 1
        println("Processing daily data for ", doy, " of ", Int(size(yield)[3] / 24))
        sif_in   = sif[:,:,i:(i+23)]
        apar_in  = apar[:,:,i:(i+23)]

        sif_out = zeros(Float32, size(sif_in)[1], size(sif_in)[2])
        apar_out = zeros(Float32, size(apar_in)[1], size(apar_in)[2])
        
        # Get mean for each gridcell in each day
        for row in 1:size(sif_in)[1] 
            for col in 1:size(sif_in)[2]
                sif_vals  = zeros(0)
                apar_vals = zeros(0)
                for time in 1:24
                    sif_val  = sif_in[row, col, time]
                    apar_val = apar_in[row, col, time]
                    if !isnan(sif_val) && sif_val != 0.0
                        append!(sif_vals, sif_val)
                    end
                    if !isnan(apar_val)
                        append!(apar_vals, apar_val)
                    end
                end
                if length(sif_vals) != 0
                    mean_sif_val = mean(sif_vals)
                else
                    mean_sif_val = NaN
                end
                if length(apar_vals) != 0
                    mean_apar_val = mean(apar_vals)
                else
                    mean_apar_val = NaN
                end
                sif_out[row, col]  = Float32.(mean_sif_val)
                apar_out[row, col] = Float32.(mean_apar_val)
            end
        end
        sif_daily[:,:,doy]  = sif_out
        apar_daily[:,:,doy] = apar_out
    end

    yield_daily = sif_daily ./ apar_daily

    # Aggregate to 8-day (works for nonleap and leap years)
    yield_8day = zeros(Float32, size(yield_daily)[1], size(yield_daily)[2], 46);
    doy = 0;
    for i in 1:8:size(yield_daily)[3]
        doy = doy + 1
        println("Processing 8-day data for ", doy, " of 46")

        # Last day is 5 or 6 days
        if doy != 46
            yield_in = yield_daily[:,:,i:(i+7)]
        else
            yield_in = yield_daily[:,:,i:size(yield_daily)[3]]
        end

        yield_out = zeros(Float32, size(yield_in)[1], size(yield_in)[2])

        for row in 1:size(yield_in)[1] 
            for col in 1:size(yield_in)[2]
                vals = zeros(0)
                for time in 1:size(yield_in)[3]
                    val = yield_in[row, col, time]
                    if !isnan(val) && val != 0.0
                        append!(vals, val)
                    end
                end
                if length(vals) != 0
                    mean_val = mean(vals)
                else
                    mean_val = NaN
                end
                yield_out[row, col] = Float32.(mean_val)
            end
        end
        yield_8day[:,:,doy] = yield_out
    end

    yield_8day = reverse(mapslices(rotl90, yield_8day, dims = [1,2]), dims = 1);  # Rotate and reverse to correct lat/lon

    return(yield_8day)
end