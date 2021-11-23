library(terra)

toclip     <- "G:/ChloFluo/product/v01/1deg/ChloFluo.GPP.v01.1deg.CF80.2019.nc" # Main directory
coastlines <- "C:/Russell/R_Scripts/TROPOMI_2/mapping/GSHHS_shp/c/GSHHS_c_L1.shp"

r <- rast(toclip)
v <- vect(coastlines)

ext(r) <- c(-180, 180, -90, 90)


class(coastlines)
extent(coastlines)
crs(coastlines)