library(lidR)
rm(list = ls(globalenv()))

# ======================================
#  READ DATA AND VISUALIZE THE CONTENT
# ======================================

# A. Basic usage
# =======================

# 1. Read a catalog and understand its content
# ------------------------------------------

ctg = readLAScatalog("data/Farm_A/")

ctg

# 2. Vizualize the catalog
# ------------------------------------------------

plot(ctg)

plot(ctg, map = TRUE)


# C. LAScatalog object are Spatial object from sp
# ===============================================

projection(ctg)
extent(ctg)
proj4string(ctg)
bbox(ctg)
ctg$Max.X
ctg$filename

# D. Corrupted dataset
# ==========================================

las_check(ctg)
