library(lidR)
rm(list = ls(globalenv()))
rgdal::set_thin_PROJ6_warnings(TRUE)

# ======================================
#  READ DATA AND VISUALIZE THE CONTENT
# ======================================

# A. Basic usage
# =======================

# 1. Read a file and understand its content
# ------------------------------------------

las = readLAS("data/MixedEucaNat_normalized.laz")

las

las@data

las@header

las@header@PHB

las@header@VLR

# https://www.asprs.org/a/society/committees/standards/LAS_1_4_r13.pdf

# 2. Vizualize the point cloud with the rgl viewer
# ------------------------------------------------

plot(las)

plot(las, clear_artifacts = FALSE)

plot(las, colorPalette = terrain.colors(50))

plot(las, color = "Intensity")

plot(las, color = "Intensity", trim = 700)

plot(las, color = "Classification")

plot(las, color = "Withheld_flag")


# B. Optimized usage
# =======================

# 1. Use the select argument to load only the attribute of interest
# ------------------------------------------------------------------

las = readLAS("data/MixedEucaNat_normalized.laz", select = "xyz")
las

plot(las)
plot(las, color = "Intensity")

# 2. Use the filter argument to load only points of interest
# ----------------------------------------------------------

# (we will study this one with more details in the next part)

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_first")

las
plot(las)

readLAS(filter = "-h")

# C. LAS objects are Spatial objects from sp
# =========================================

projection(las)
extent(las)
proj4string(las)
bbox(las)
las$Z
las$Intensity

# D. Check corrupted dataset
# ==========================================

las = readLAS("data/MixedEucaNat_normalized.laz")

las_check(las)

las = readLAS("data/example_corrupted.laz")
plot(las)

las_check(las)

las = readLAS("data/exemple_rgb.las")
plot(las)

las_check(las)

plot(las, color = "RGB")


# E. Exercise and/or questions
# =============================

# 1. Why do we work with las/laz files instead of text files?
# 2. How to write a LAS file?



