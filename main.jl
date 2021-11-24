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

#########
#
# Stress
#
#########

# Determine LSWImax
lswimax = max_lswi("/mnt/g/ChloFluo/input/LSWI/1deg/MCD43C4.A.2020.LSWI.8-day.1deg.nc", 1.0);
heatmap(lswimax, title = "Maximum LSWI", bg = :white, color = :viridis, clims = (-1.0, 1.0))
save_nc(lswimax, "/mnt/g/ChloFluo/input/LSWImax/1deg/LSWImax.8-day.1deg.2020.nc", 2020, "LSWImax", "Maximum LSWI", "");

# Calculate Daytime Average Temperature
temp_day = calc_temp_day("/mnt/g/ChloFluo/input/Temp/era/Temp.ERA.2018.nc");
heatmap(temp_day[:,:,23], title = "Daytime Average Temperature", bg = :white, color = :viridis)
save_nc(temp_day, "/mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2018.nc", 2018, "t2m_daytime", "Mean Daytime 2m Air Temperature", "C");

# Make Topt, Tmin, and Tmax maps
topt, tmin, tmax = tparams("/mnt/g/ChloFluo/input/landcover/mcd12c1/original/MCD12C1.A2019001.006.2020220162300.hdf");
heatmap(topt, title = "Optimum Temperature", bg = :white, color = :viridis)
heatmap(tmin, title = "Minimum Temperature", bg = :white, color = :viridis)
heatmap(tmax, title = "Maximum Temperature", bg = :white, color = :viridis)
save_nc(topt, "/mnt/g/ChloFluo/input/Temp/opt/5km/topt.5km.2019.nc", 2019, "topt", "Optimum Temperature", "C");
save_nc(tmin, "/mnt/g/ChloFluo/input/Temp/opt/5km/tmin.5km.2019.nc", 2019, "tmin", "Optimum Temperature", "C");
save_nc(tmax, "/mnt/g/ChloFluo/input/Temp/opt/5km/tmax.5km.2019.nc", 2019, "tmax", "Optimum Temperature", "C");


