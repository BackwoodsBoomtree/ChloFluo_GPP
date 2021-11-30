library(terra)
library(viridis)

data       <- "G:/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc"
coastlines <- "C:/Russell/R_Scripts/TROPOMI_2/mapping/GSHHS_shp/c/GSHHS_c_L1.shp"

r <- rast(data)
v <- vect(coastlines)

##### Clip to shapefile #####
clipped <- mask(r, v, touches = FALSE)

# 
# ##### OPTIONAL: Remove pixels with low n for the year #####
# len <- function(x) {
#   length(x[!is.na(x)])
# }
# 
# count <- app(clipped, fun = len)


##### Set NAs to 0 where values appear during the year #####

# Get map of all gridcells that had a value in the year for masking
mask <- app(clipped, "mean", na.rm = TRUE)
mask[mask >= 0] <- 1
mask[is.nan(mask)] <- 0

# Compare values in mask and source layer and replace NaN in source with 0
# if mask indicates there is a value for that gridcell in the time series
val_m <- values(mask)

for (i in 1:nlyr(clipped)) {
  val_s <- values(clipped[[i]])
  val_new <- matrix(0, nrow = nrow(val_m), ncol = ncol(val_m))
  
  for (j in 1:length(val_s)) {
    if (is.nan(val_s[j]) && val_m[j] == 1) {
      val_new[j] <- 0
    } else {
      val_new[j] <- val_s[j]
    }
  }
  values(clipped[[i]]) <- val_new
}


plot(clipped[[1]], xlim = c(100,150), ylim = c(-10, 10))
plot(v, add = TRUE)

writeCDF(clipped, "G:/ChloFluo/product/v01/1deg/clipfill/ChloFluo.GPP.v01.1deg.CF80.2019.clipfill.nc",
         varname = "gpp", longname = "Gross Primary Production", unit = "g C/m-2/day-1",
         missval = -9999, overwrite = TRUE)
