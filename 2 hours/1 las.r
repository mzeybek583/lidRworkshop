library(lidR)
rm(list = ls(globalenv()))

# ======================================
#  READ DATA AND VISUALIZE THE CONTENT
# ======================================

# A. Basic usage
# =======================

las = readLAS("data/MixedEucaNat_normalized.laz")
las

projection(las)
extent(las)

plot(las)

plot(las, colorPalette = terrain.colors(50))

plot(las, color = "Intensity")

plot(las, color = "Intensity", trim = 800)

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

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_first")
las

plot(las)

# C. LAS objects validation
# =========================================

las_check(las)




