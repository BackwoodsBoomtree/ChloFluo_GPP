library(terra)

toclip     <- "G:/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc"
coastlines <- "C:/Russell/R_Scripts/TROPOMI_2/mapping/GSHHS_shp/c/GSHHS_c_L1.shp"

r <- rast(toclip)
v <- vect(coastlines)

clipped <- mask(r, v, touches = FALSE)

plot(clipped[[1]], xlim = c(100,150), ylim = c(-10, 10))
plot(v, add = TRUE)

writeCDF(clipped, "G:/ChloFluo/product/v01/1deg/clipped/ChloFluo.GPP.v01.1deg.CF80.2019.clip.nc",
         varname = "gpp", longname = "Gross Primary Production", unit = "g C/m-2/day-1",
         missval = -9999, overwrite = TRUE)
