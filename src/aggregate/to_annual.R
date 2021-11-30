library(terra)
library(viridis)

# To get the annual mean for a grid cell, we need to calculate 0 GPP for the time periods
# where there was an NA.

data <- "G:/ChloFluo/product/v01/1deg/clipfill/ChloFluo.GPP.v01.1deg.CF80.2019.clipfill.nc"

series <- rast(data)

annual_mean <- mean(series, na.rm = TRUE)

writeCDF(annual_mean, "G:/ChloFluo/product/v01/1deg/clipfill/annual/ChloFluo.GPP.v01.1deg.CF80.2019.clipfill.annual.nc",
         varname = "gpp", longname = "Gross Primary Production", unit = "g C/m-2/day-1",
         missval = -9999, overwrite = TRUE)


annual_mean[annual_mean > 25] <- 25
plot(annual_mean, col = viridis(25))
