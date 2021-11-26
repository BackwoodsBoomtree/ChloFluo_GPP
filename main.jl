###############################################################################
#
# Main code for running complete ChloFluo model in order
#
# GPP = APARchl * LUEmax * Stress
#
###############################################################################

using ChloFluo
using Plots, Colors

######### APARchl #########

# Quality control gridded SIF values
sifqc = sif_qc("/mnt/g/TROPOMI/esa/gridded/1deg/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.1deg.CF80.nc", "SIF_Corr_743", "n", "SIF_Corr_743_std", 32, 77);
heatmap(sifqc[:,:,23], title = "SIF QCed", bg = :white, color = :viridis)
save_nc(sifqc, "/mnt/g/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc", 2019, "sif743_qc", "SIF743 Quality Controlled", "mW/m²/sr/nm");

# Calculate SIFyield
sifyield = calc_yield("/mnt/g/CLIMA/clima_land_2019_1X_1H.hs.nc");
heatmap(sifyield[:,:,23], title = "SIFyield", bg = :white, color = :viridis)
save_nc(sifyield, "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc", 2019, "sif_yield", "Quantum Yield of Fluorescence", "mJ nm-1 sr-1 umol-1");

# Calculate APARchl
apar = calc_apar("/mnt/g/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc", "/mnt/g/ChloFluo/input/yield/1deg/yield.2019.8-day.1deg.nc");
heatmap(apar[:,:,23], title = "APAR Chlorophyll", bg = :white, color = :viridis)
save_nc(apar, "/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc", 2019, "aparchl", "Absorbed PAR by Chlorophyll", "μmol/m-2/day-1");


######### LUEmax #########

# Calculate LUEmax
luemax = calc_luemax("/mnt/g/ChloFluo/input/C3C4/ISLSCP/c4_percent_1d.nc");
heatmap(luemax, title = "Maximum LUE", bg = :white, color = :viridis)
save_nc(luemax, "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc", 2019, "LUEmax", "Maximum Light Use Efficiency", "g C / mol");


######### Stress #########

# Determine LSWImax
lswimax = max_lswi("/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2019.LSWI.8-day.1deg.nc", 1.0);
heatmap(lswimax, title = "Maximum LSWI", bg = :white, color = :viridis, clims = (-1.0, 1.0))
save_nc(lswimax, "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2019.nc", 2019, "LSWImax", "Maximum LSWI", "");

# Calculate Water Scalar
wscalar = calc_wscalar("/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2019.LSWI.8-day.1deg.nc", "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2019.nc");
heatmap(wscalar[:,:,23], title = "Water Scalar", bg = :white, color = :viridis)
save_nc(wscalar, "/mnt/g/ChloFluo/input/wscalar/1deg/wscalar.8-day.1deg.2019.nc", 2019, "wscalar", "Water Scalar", "");

# Calculate Daytime Average Temperature
temp_day = calc_temp_day("/mnt/g/ChloFluo/input/Temp/era/Temp.ERA.2019.nc");
heatmap(temp_day[:,:,23], title = "Daytime Average Temperature", bg = :white, color = :viridis)
save_nc(temp_day, "/mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2019.nc", 2019, "t2m_daytime", "Mean Daytime 2m Air Temperature", "C");
# Aggregate
run(`cdo -b f32 remapcon,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2019.nc /mnt/g/ChloFluo/input/Temp/daytime/1deg/8day/Temp.mean.daytime.8day.era.1deg.2019.nc`)

# Make Topt, Tmin, and Tmax maps
topt, tmin, tmax = tparams("/mnt/g/ChloFluo/input/landcover/mcd12c1/original/MCD12C1.A2019001.006.2020220162300.hdf");
heatmap(topt, title = "Optimum Temperature", bg = :white, color = :viridis)
heatmap(tmin, title = "Minimum Temperature", bg = :white, color = :viridis)
heatmap(tmax, title = "Maximum Temperature", bg = :white, color = :viridis)
save_nc(topt, "/mnt/g/ChloFluo/input/Temp/opt/5km/topt.5km.2019.nc", 2019, "topt", "Optimum Temperature", "C");
save_nc(tmin, "/mnt/g/ChloFluo/input/Temp/opt/5km/tmin.5km.2019.nc", 2019, "tmin", "Minimum Temperature", "C");
save_nc(tmax, "/mnt/g/ChloFluo/input/Temp/opt/5km/tmax.5km.2019.nc", 2019, "tmax", "Maximum Temperature", "C");
run(`cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/opt/5km/topt.5km.2019.nc /mnt/g/ChloFluo/input/Temp/opt/1deg/topt.1deg.2019.nc`)
run(`cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/min/5km/tmin.5km.2019.nc /mnt/g/ChloFluo/input/Temp/min/1deg/tmin.1deg.2019.nc`)
run(`cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/max/5km/tmax.5km.2019.nc /mnt/g/ChloFluo/input/Temp/max/1deg/tmax.1deg.2019.nc`)

# Calculate Temperature Scalar
tscalar = calc_tscalar("/mnt/g/ChloFluo/input/Temp/daytime/1deg/8day/Temp.mean.daytime.8day.era.1deg.2019.nc", "/mnt/g/ChloFluo/input/Temp/opt/1deg/topt.1deg.2019.nc", "/mnt/g/ChloFluo/input/Temp/min/1deg/tmin.1deg.2019.nc", "/mnt/g/ChloFluo/input/Temp/max/1deg/tmax.1deg.2019.nc");
heatmap(tscalar[:,:,23], title = "Temperature Scalar", bg = :white, color = :viridis)
save_nc(tscalar, "/mnt/g/ChloFluo/input/tscalar/1deg/tscalar.8-day.1deg.2019.nc", 2019, "tscalar", "Temperature Scalar", "");

# Calculate Stress
stress = calc_stress("/mnt/g/ChloFluo/input/tscalar/1deg/tscalar.8-day.1deg.2019.nc", "/mnt/g/ChloFluo/input/wscalar/1deg/wscalar.8-day.1deg.2019.nc");
heatmap(stress[:,:,23], title = "Stress Scalar", bg = :white, color = :viridis)
save_nc(stress, "/mnt/g/ChloFluo/input/stress/1deg/stress.8-day.1deg.2019.nc", 2019, "stress", "Stress Scalar", "");


######### GPP #########

gpp = calc_gpp("/mnt/g/ChloFluo/input/APARchl/1deg/apar.2019.8-day.1deg.nc", "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc", "/mnt/g/ChloFluo/input/stress/1deg/stress.8-day.1deg.2019.nc");
heatmap(gpp[:,:,23], title = "Gross Primary Production", bg = :white, color = :viridis)
save_nc(gpp, "/mnt/g/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc", 2019, "gpp", "Gross Primary Production", "g C/m-2/day-1");