
library(terra)

map_sd <- function(in_file, variable) {
  
  data    <- sds(in_file)
  index   <- which(names(data) == variable)
  
  if (length(index) != 0){
    data    <- data[[index]]
    data_sd <- app(data, fun = sd, na.rm = TRUE)
  } else {
    stop("Variable not found in the input file.")
  }
  
  return(data_sd)
}

in_file  <- "G:/TROPOMI/esa/gridded/20km/8day/TROPOMI.ESA.SIF.201805-202109.global.8day.20km.CF20.nc"

sif743_sd <- map_sd(in_file, "SIF_743")
nirv_sd   <- map_sd(in_file, "NIRv")


