library(raster)
library(rgdal)
library(RColorBrewer)
library(viridis)

#### Load Map ####

coastlines <- readOGR("C:/Russell/R_Scripts/TROPOMI_2/mapping/GSHHS_shp/c/GSHHS_c_L1.shp")
class(coastlines)
extent(coastlines)
crs(coastlines)

#### Load the data ####

# 8 day

km20_8day_R2  <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/20km/8day/TROPOMI_SIF743_vs_NIRv_0.20_global_clearksy_201805-202108_Rsquare.tif")
km20_8day_Pv  <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/20km/8day/TROPOMI_SIF743_vs_NIRv_0.20_global_clearksy_201805-202108_Pval.tif")
km100_8day_R2 <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/1deg/8day/TROPOMI_SIF743_vs_NIRv_1deg_8day_global_clearsky_201805-202109_Rsquare.tif")
km100_8day_Pv <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/1deg/8day/TROPOMI_SIF743_vs_NIRv_1deg_8day_global_clearsky_201805-202109_Pval.tif")

# monthly

km20_month_R2  <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/20km/monthly/TROPOMI.SIF743_vs_NIRv.201805-202109.global.clearsky.monthly.20km._Rsquare.tif")
km20_month_Pv  <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/20km/monthly/TROPOMI.SIF743_vs_NIRv.201805-202109.global.clearsky.monthly.20km._Pval.tif")
km100_month_R2 <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/1deg/monthly/TROPOMI_SIF743_vs_NIRv_1deg_monthly_global_clearsky_201805-202109_Rsquare.tif")
km100_month_Pv <- raster("G:/Russell/Projects/ChloFluo/raster_regressions/global_clearsky/SIF743_NIRv/1deg/monthly/TROPOMI_SIF743_vs_NIRv_1deg_monthly_global_clearsky_201805-202109_Pval.tif")

# Mask variables out by pvalue
km20_8day_Pv[km20_8day_Pv>0.05]     <- NA
km100_8day_Pv[km100_8day_Pv>0.05]   <- NA
km20_month_Pv[km20_month_Pv>0.05]   <- NA
km100_month_Pv[km100_month_Pv>0.05] <- NA

km20_8day_R2   <- mask(km20_8day_R2, km20_8day_Pv)
km100_8day_R2  <- mask(km100_8day_R2, km100_8day_Pv)
km20_month_R2  <- mask(km20_month_R2, km20_month_Pv)
km100_month_R2 <- mask(km100_month_R2, km100_month_Pv)

# Adjust extent

new_ext        <- extent(-180, 180, -60, 85)
km20_8day_R2   <- crop(km20_8day_R2, new_ext)
km100_8day_R2  <- crop(km100_8day_R2, new_ext)
km20_month_R2  <- crop(km20_month_R2, new_ext)
km100_month_R2 <- crop(km100_month_R2, new_ext)

#### PLOT STUFF ####

# Colors
r2.col <- plasma(100)

labs <- c(expression(paste("8-day SIF vs NIRv 0.20°")), expression(paste("8-day SIF vs NIRv 1.0°")),
          expression(paste("Monthly SIF vs NIRv 0.20°")), expression(paste("Monthly SIF vs NIRv 1.0°")))
          
#### R2 Maps ####
pdf("G:/Russell/Projects/ChloFluo/figures/Maps_SIFvsNIRv_clearsky.pdf", width=7.5, height=6, compress=FALSE)

par(mfrow=c(3,2),oma=c(0,0.25,1.25,0))

##### 8-day 20km ####
op <- par(mar = c(0,0,0.25,0.25))
plot(km20_8day_R2, axes=F, xaxs="i", yaxs="i", horizontal=T, legend=F, col = NA)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(coastlines, add = TRUE, border = NA, col = "gray")
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(km20_8day_R2, zlim=c(0.1,1), col=r2.col, axes=F, xaxs="i", yaxs="i", legend=F, horizontal=T, add=T)
mtext(3, text=labs[1], cex=0.85)
mtext(3, text="a", cex= 0.85, adj=0, font=2)
plot(coastlines, add = TRUE, lwd=0.5)

plot(km20_8day_R2, zlim=c(0.1,1), legend.only=TRUE, col=r2.col, horizontal=T, legend.width=2, legend.shrink=0.75,
     legend.args = list(text=expression(paste("R"^"2")), side = 1, line = -2, cex=0.85),
     axis.args = list(line = -1.05, cex.axis=1,tick=F, at=c(0.1,1), labels=c("0.1","1")),
     smallplot=c(0.40,0.90,0.2,0.25)); par(mar = par("mar"))

par(new=TRUE)
op <- par(mar = c(2.1,0.25,8,21))  
hist(km20_8day_R2, col="gray75", breaks=9, ylim=c(0,120000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "white",border = NA)
med <- round(median(as.vector(km20_8day_R2), na.rm = T), 2)
abline(v=med, col="red")
axis(3, tck=F, labels=med, at=med, mgp=c(3, 0.1, 0))
hist(km20_8day_R2, col="gray75", breaks=9, ylim=c(0,120000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE, add=T)
box()

##### 8-day 1deg ####
op <- par(mar = c(0,0,0.25,0.25))
plot(km100_8day_R2, axes=F, xaxs="i", yaxs="i", horizontal=T, legend=F, col = NA)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(coastlines, add = TRUE, border = NA, col = "gray")
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(km100_8day_R2, zlim=c(0.1,1), col=r2.col, axes=F, xaxs="i", yaxs="i", legend=F, horizontal=T, add=T)
mtext(3, text=labs[2], cex=0.85)
mtext(3, text="b", cex= 0.85, adj=0, font=2)
plot(coastlines, add = TRUE, lwd=0.5)

plot(km100_8day_R2, zlim=c(0.1,1), legend.only=TRUE, col=r2.col, horizontal=T, legend.width=2, legend.shrink=0.75,
     legend.args = list(text=expression(paste("R"^"2")), side = 1, line = -2, cex=0.85),
     axis.args = list(line = -1.05, cex.axis=1,tick=F, at=c(0.1,1), labels=c("0.1","1")),
     smallplot=c(0.40,0.90,0.2,0.25)); par(mar = par("mar"))

par(new=TRUE)
op <- par(mar = c(2.1,0.25,8,21)) 
hist(km100_8day_R2, col="gray75", breaks=9, ylim=c(0,8000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "white",border = NA)
med <- round(median(as.vector(km100_8day_R2), na.rm = T), 2)
abline(v=med, col="red")
axis(3, tck=F, labels=med, at=med, mgp=c(3, 0.1, 0))
hist(km100_8day_R2, col="gray75", breaks=9, ylim=c(0,8000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE, add=T)
box()

##### Monthly 20km ####
op <- par(mar = c(0,0,0.25,0.25))
plot(km20_month_R2, axes=F, xaxs="i", yaxs="i", horizontal=T, legend=F, col = NA)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(coastlines, add = TRUE, border = NA, col = "gray")
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(km20_month_R2, zlim=c(0.1,1), col=r2.col, axes=F, xaxs="i", yaxs="i", legend=F, horizontal=T, add=T)
mtext(3, text=labs[3], cex=0.85)
mtext(3, text="c", cex= 0.85, adj=0, font=2)
plot(coastlines, add = TRUE, lwd=0.5)

plot(km20_month_R2, zlim=c(0.1,1), legend.only=TRUE, col=r2.col, horizontal=T, legend.width=2, legend.shrink=0.75,
     legend.args = list(text=expression(paste("R"^"2")), side = 1, line = -2, cex=0.85),
     axis.args = list(line = -1.05, cex.axis=1,tick=F, at=c(0.1,1), labels=c("0.1","1")),
     smallplot=c(0.40,0.90,0.2,0.25)); par(mar = par("mar"))

par(new=TRUE)
op <- par(mar = c(2.1,0.25,8,21))
hist(km20_month_R2, col="gray75", breaks=9, ylim=c(0,120000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "white",border = NA)
med <- round(median(as.vector(km20_month_R2), na.rm = T), 2)
abline(v=med, col="red")
axis(3, tck=F, labels=med, at=med, mgp=c(3, 0.1, 0))
hist(km20_month_R2, col="gray75", breaks=9, ylim=c(0,120000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE, add=T)
box()

##### Monthly 1deg ####
op <- par(mar = c(0,0,0.25,0.25))
plot(km100_month_R2, axes=F, xaxs="i", yaxs="i", horizontal=T, legend=F, col = NA)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(coastlines, add = TRUE, border = NA, col = "gray")
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = NA)
plot(km100_month_R2, zlim=c(0.1,1), col=r2.col, axes=F, xaxs="i", yaxs="i", legend=F, horizontal=T, add=T)
mtext(3, text=labs[4], cex=0.85)
mtext(3, text="d", cex= 0.85, adj=0, font=2)
plot(coastlines, add = TRUE, lwd=0.5)

plot(km100_month_R2, zlim=c(0.1,1), legend.only=TRUE, col=r2.col, horizontal=T, legend.width=2, legend.shrink=0.75,
     legend.args = list(text=expression(paste("R"^"2")), side = 1, line = -2, cex=0.85),
     axis.args = list(line = -1.05, cex.axis=1,tick=F, at=c(0.1,1), labels=c("0.1","1")),
     smallplot=c(0.40,0.90,0.2,0.25)); par(mar = par("mar"))

par(new=TRUE)
op <- par(mar = c(2.1,0.25,8,21)) 
hist(km100_month_R2, col="gray75", breaks=9, ylim=c(0,8000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE)
rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "white",border = NA)
med <- round(median(as.vector(km100_month_R2), na.rm = T), 2)
abline(v=med, col="red")
axis(3, tck=F, labels=med, at=med, mgp=c(3, 0.1, 0))
hist(km100_month_R2, col="gray75", breaks=9, ylim=c(0,8000), xlim=c(0.1,1), xaxs="i", yaxs="i", ann=FALSE, axes=FALSE, add=T)
box()

dev.off()
