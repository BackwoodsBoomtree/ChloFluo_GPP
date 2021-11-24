
###############################################################################
#
# Calculate APARchl
#
# 
#
###############################################################################

sif_file    = "/mnt/g/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc";
yield_file  = "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc";
output_nc   = "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc";
year        = 2019;
var_sname   = "aparchl";
var_lname   = "Absorbed PAR by Chlorophyll";
unit        = "μmol/m⁻²/day⁻¹";

function calc_apar(sif, yield)
    sif    = Dataset(sif)["sif743_qc"][:,:,:]
    yield  = Dataset(yield)["SIFyield"][:,:,:]

    # Arrange rasters dims to match
    sif    = replace!(sif, missing => NaN)
    yield  = replace!(yield, missing => NaN)

    apar             = sif ./ yield
    apar             = replace!(apar, missing => NaN)
    apar[apar .< 0] .= NaN;
    apar             = permutedims(apar, [2,1,3])

    save_nc(apar, output_nc, year, var_sname, var_lname, unit)
end

calc_apar(sif_file, yield_file);

# Take a look
# heatmap(apar[:,:,23], bg = :white, color = :viridis)