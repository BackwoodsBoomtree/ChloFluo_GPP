using ChloFluo
using Plots, Colors


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

# Calculate LUEmax
luemax = calc_luemax("/mnt/g/ChloFluo/input/C3C4/ISLSCP/c4_percent_1d.nc");
heatmap(luemax, title = "Maximum LUE", bg = :white, color = :viridis)
save_nc(luemax, "/mnt/g/ChloFluo/input/LUE/1deg/LUEmax.1deg.nc", 2019, "LUEmax", "Maximum Light Use Efficiency", "g C / mol");

