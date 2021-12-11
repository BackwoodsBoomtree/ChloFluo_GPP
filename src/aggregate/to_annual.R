library(terra)
library(viridis)

# To get the annual mean for a grid cell, we need to calculate 0 GPP for the time periods
# where there was an NA.

data <- "G:/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.nc"

series <- rast(data)

annual_mean <- mean(series, na.rm = TRUE)

writeCDF(annual_mean, "G:/ChloFluo/input/SIF/1deg/SIFqc.8day.1deg.CF80.2019.annual.nc",
         varname = "sif743_qc", longname = "SIF743 Quality Controlled", unit = "mW/m-2/sr/nm",
         missval = -9999, overwrite = TRUE)


annual_mean[annual_mean > 15] <- 15
plot(annual_mean, col = viridis(15))
