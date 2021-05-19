library(lidR)
rm(list = ls(globalenv()))

# ======================================
#         OTHER LASFUNCTIONS
# ======================================

# We have already seen several function families:
#
# - io: to read and write LAS object in las/laz files
# - filter_*: to select points of interest (return LAS objects)
# - clip_*: to select regions of interest (return LAS objects)
# - grid_*: to rasterize the point cloud (return Raster* objects)
#
# We now introduce the other functions that return LAS objects

las = readLAS("data/MixedEucaNat_normalized.laz")

# A. merge_spatial: merge geographic data with the point cloud
# ==========================================================

# 1. With a shapefile of polygons
# -------------------------------

# Load a shapefile

eucalyptus = shapefile("data/shapefiles/MixedEucaNat.shp")

# Merge with the point cloud

lasc = lasmergespatial(las, eucalyptus, "in_plantation")
lasc

# Visualize

plot(lasc, color = "in_plantation")

# Do something: here, for the example, we simply filter the points. You can imagine any application

not_plantation = filter_poi(lasc, in_plantation == FALSE)
plot(not_plantation)

# 2. With a raster
# ----------------------------

# /!\ NOTICE /!\
# In the past it was possible to get an easy access to the google map API via R to get satellite
# images. Former example consisted in RGB colorization of the point cloud. It is no longer possible
# to access to the google API without a registration key. Thus I replaced the RGB colorization by a
# less nice example.

# Make a raster. Here a CHM

chm = grid_canopy(las, 1, p2r())
plot(chm, col = height.colors(50))

# Merge with the point cloud

lasc = merge_spatial(las, chm, "hchm")
lasc

# Do something. Here for the example we simply filter a layer below the canopy.
# You can imagine any application. RGB colorization was one of them.

layer = filter_poi(lasc, Z > hchm - 1)
plot(layer)

not_layer = filter_poi(lasc, Z < hchm - 1)
plot(not_layer)

# Former example: that works only wit a google map API key.
# ------------------------------------------------------------------

library(dismo)

bbox  <- extent(las)
proj4 <- proj4string(las)

r <- raster()
extent(r) <- bbox
proj4string(r) <- proj4

gm  <- gmap(x = r, type = "satellite", scale = 2, rgb = TRUE)
plotRGB(gm)

gm <- projectRaster(gm, crs = proj4)

las <- merge_spatial(las, gm)

plot(las, color = "RGB")

las_check(las)


# B. Memory usage consideration
# ===============================

pryr::object_size(las)
pryr::object_size(lasc)

pryr::object_size(las, lasc)

# This is true for any functions that does not change the number of points i.e
# almost all the functions but filter_*, clip_*

# C. smooth_height: point-cloud-based smoothing
# =========================================

# Smooth the point cloud
lass = smooth_height(las, 4)

plot(lass)

# It is not really useful. It may become interesting combined with lasfiltersurfacepoints

lassp = filter_surfacepoints(las, 0.5)
lass = smooth_height(lassp, 2)

plot(lassp)
plot(lass)

# D. add_attribute: add data to a LAS object
# ========================================

A <- runif(nrow(las@data), 10, 100)

# Forbidden

las$Amplitude <- A

# The reason is to force the user to read the documentation of lasadddata
?add_attribute

# add_attribute does what you might expect using <-

las_new = add_attribute(las, A, "Amplitute")

# But the header is not updated

las_new@header

# add_lasattribute actually adds data in a way that enables the data to be written in las files

las_new = add_lasattribute(las, A, "Amplitude", "Pulse amplitude")

# The header has been updated

las_new@header

# E: classify_ground: segment ground points
# =======================================

las = readLAS("data/MixedEucaNat.laz")
plot(las)

# The original file contains an outlier

hist(las$Z, n = 30)
range(las$Z)

# Read the file skipping the outlier

las = readLAS("data/MixedEucaNat.laz", filter = "-drop_z_below 740")
plot(las)

# The file is already classified. For the purpose of the example we can clear this classification

las$Classification = 0 # Error, explain why.

plot(las, color = "Classification")

# Segment the ground points with classify_ground

las = classify_ground(las, csf(rigidness = 2.5))

plot(las, color = "Classification")

ground = filter_ground(las)
plot(ground)

# F. normalize_height: remove topography
# ===================================

# 1. With a DTM
# -------------

dtm = grid_terrain(las, 1, tin())

plot(dtm, col = height.colors(50))
plot_dtm3d(dtm)

lasn = las - dtm

plot(lasn)

las_check(lasn)


# 2. Without a DTM
# -----------------

lasn = normalize_height(las, tin())
plot(lasn)

las_check(lasn)

# Explain the difference between the two methods

# G. Other functions
# ========================

# find_trees (see next section)
# segment_trees (see next section)
# segment_snags
# segment_shapes
# unsmooth_height
# unormalize_height
# classify_noise
# decimate_points
# ...
