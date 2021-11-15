#!/bin/bash

cd /home/boomtree/Git/ChloFlo/ChloFluo_GPP/ChloFluo/src/aggregate

##### Temp Data

# Daytime Mean Temp
# Permute if needed:
ncpdq -a time,lat,lon /mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2020.nc /mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2020.nc

cdo -b f32 remapcon,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/daytime/25km/8day/Temp.mean.daytime.8day.era.25km.2020.nc /mnt/g/ChloFluo/input/Temp/daytime/1deg/8day/Temp.mean.daytime.8day.era.1deg.2020.nc

# Opt, Min, Max T
cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/opt/5km/topt.5km.2019.nc /mnt/g/ChloFluo/input/Temp/opt/1deg/topt.1deg.2019.nc
cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/min/5km/tmin.5km.2019.nc /mnt/g/ChloFluo/input/Temp/min/1deg/tmin.1deg.2019.nc
cdo -b f32 remapnn,gridfile_1.0.txt /mnt/g/ChloFluo/input/Temp/max/5km/tmax.5km.2019.nc /mnt/g/ChloFluo/input/Temp/max/1deg/tmax.1deg.2019.nc

