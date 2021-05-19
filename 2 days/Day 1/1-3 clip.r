library(lidR)
rm(list = ls(globalenv()))

# ======================================
#    SELECTION OF REGIONS OF INTEREST
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz", select = "*")

?clip_roi

# A. Select simple geometries
# =============================

subset = clip_circle(las, 203890, 7358935, 30)

plot(subset)

subset2 = clip_rectangle(las, 203890, 7358935, 203890 + 40, 7358935 + 30)

plot(subset2)


x = runif(2, 203830, 203980)
y = runif(2, 7358900, 7359050)

subsets1 = clip_circle(las, x, y, 30)

subsets1

plot(subsets1[[1]])
plot(subsets1[[2]])


# B. Think about memory usage !!
# ==============================

# clip_* functions are filter functions. They create copies. When manipulating *big* data, one must
# be careful. Lidar point clouds may be huge. Here it does not matter.

pryr::object_size(las)
pryr::object_size(subset)
pryr::object_size(subset2)

pryr::object_size(las, subset, subset2)


# C. For simple geometries we can use the filter argument from readLAS
# ===================================================================

subset3 = readLAS("data/MixedEucaNat_normalized.laz", select = "xyz", filter = "-keep_circle 203890 7358935 30")

plot(subset3)

# D. Extraction of complex geometries
# ====================================

planting = shapefile("data/shapefiles/MixedEucaNat.shp")

plot(las@header, map = FALSE)
plot(planting, add = TRUE)


eucalyptus = clip_roi(las, planting)

plot(eucalyptus)
