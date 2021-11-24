library(terra)

toclip     <- "G:/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc" # Main directory
coastlines <- "C:/Russell/R_Scripts/TROPOMI_2/mapping/GSHHS_shp/c/GSHHS_c_L1.shp"

r <- rast(toclip)
v <- vect(coastlines)

test <- mask(r, v, touches = FALSE)

plot(test[[1]], xlim = c(100,150), ylim = c(-10, 10))
plot(v, add = TRUE)

