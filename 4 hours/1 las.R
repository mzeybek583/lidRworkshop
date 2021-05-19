options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)
library(sf)


# ======================================
#  READ DATA AND VISUALIZE THE CONTENT
# ======================================

# A. Basic usage
# =======================

las = readLAS("data/MixedEucaNat_normalized.laz") # Warning explained later
print(las)

crs(las)
projection(las)
st_crs(las)

extent(las)
bbox(las)
st_bbox(las)

plot(las)
plot(las, colorPalette = terrain.colors(50))
plot(las, color = "Intensity")
plot(las, color = "Classification")
plot(las, color = "ScanAngleRank", axis = TRUE, legend = T)

las@header
las@data

format(object.size(las), "Mb")

# B. Optimized usage
# =======================

# 1. Use the select argument to load only the attribute of interest
# ------------------------------------------------------------------

las = readLAS("data/MixedEucaNat_normalized.laz", select = "xyz")
las
las@data

format(object.size(las), "Mb")

plot(las)
plot(las, color = "Intensity")


# 2. Use the filter argument to load only points of interest
# ----------------------------------------------------------

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_first")
las

format(object.size(las), "Mb")

plot(las)

# 3. Use the filter argument to apply a transformation to the points on-the-fly
# -----------------------------------------------------------

readLAS(filter = "-h")
rlas::read.las(transform = "-h")

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-classify_intensity_above_as 450 11")

plot(las, color = "Classification", legend = T)

# C. LAS objects validation
# =========================================

las = readLAS("data/MixedEucaNat_normalized.laz")
las_check(las)

las = readLAS("data/example_corrupted.laz")
plot(las)
las_check(las)

las = readLAS("data/exemple_rgb.las")
plot(las, color = "RGB")
las_check(las)

# D. Exercises and questions
# =========================================

# Using MixedEucaNat_normalized.laz

las = readLAS("data/MixedEucaNat_normalized.laz")

# - What are the withheld point?
# - Where are they?
# - Read the file dropping the withheld points
# - The withheld points seem legit points. Try to load the file including the withheld point
#   but get rid of the warning (without using suppressWarnings()). (Hint: use transformation)
# - Load only the ground points and plot the point cloud by the return number of the point.
#   Do it loading the strict minimal amount of memory (4.7 Mb)








