options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)


# ======================================
#    SELECTION OF REGIONS OF INTEREST
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz",  filter = "-set_withheld_flag 0")

?clip_roi

# A. Select simple geometries
# =============================

subset = clip_circle(las, 203890, 7358935, 30)

subset

plot(subset)

subset2 = clip_rectangle(las, 203890, 7358935, 203890 + 40, 7358935 + 30)

plot(subset2)

x = runif(2, 203830, 203980)
y = runif(2, 7358900, 7359050)

subsets1 = clip_circle(las, x, y, 30)

subsets1

plot(subsets1[[1]])
plot(subsets1[[2]])


# D. Extraction of complex geometries from shapefile
# ====================================

planting = shapefile("data/shapefiles/MixedEucaNat.shp")

plot(las@header, map = FALSE)
plot(planting, add = TRUE, col = "#08B5FF39")

eucalyptus = clip_roi(las, planting)

plot(eucalyptus)

# for sf users
library(sf)
planting = st_read("data/shapefiles/MixedEucaNat.shp", quiet = T)

plot(las@header, map = FALSE)
plot(planting, add = TRUE, col = "#08B5FF39")

eucalyptus = clip_roi(las, planting)

# E. Exercise and questions
# ====================================

# Using:
plots = shapefile("data/shapefiles/MixedEucaNatPlot.shp")
plot(las@header, map = FALSE)
plot(plots, add = TRUE)

# - clip the 5 plots with a radius of 11.3 m
# - clip a transect from A(203850, 7358950) to B(203950, 7959000)
# - clip a transect from A(203850, 7358950) to B(203950, 7959000) but rotate it in such a way
#   that it is no longer in the XY diagonal (convenient for plotting for example)
