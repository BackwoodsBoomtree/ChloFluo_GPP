###############################################################################
#
# Calculate Maximum LSWI for each year for Wscalar 
#
# Input are the 8-day 0.05-degree MCD43C4 LSWI nc files, which are annual.
# Codes for producting LSWI are here: https://github.com/GeoCarb-OU/MCD43C4_VIs
#
# Output is one file for each year.
#
###############################################################################

function max_lswi(file::String)
    println(file)
end

max_lswi("okay")