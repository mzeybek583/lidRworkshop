options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)

# ======================================
#         DIGITAL TERRAIN MODEL
# ======================================

# A. DTM
# =======================

las = readLAS("data/MixedEucaNat.laz", filter = "-set_withheld_flag 0")
col = height.colors(50)

plot(las)
plot(las, color = "Classification")

# Triangulate the ground points
dtm = grid_terrain(las, 1, tin())

plot(dtm)
plot_dtm3d(dtm)

x = plot(las)
add_dtm3d(x, dtm)

# Inverse-distance weighting of the ground points
dtm = grid_terrain(las, 1, knnidw())
plot(dtm)
plot_dtm3d(dtm)

# B. Normalization
# =======================

# DTM-based normalization
# ------------------------

nlas = normalize_height(las, dtm)
plot(nlas)

gnd = filter_ground(nlas)
hist(gnd$Z, breaks = seq(-1.5,1.5,0.05))

# Shortcut
nlas = las - dtm

# point-based normalization
# -------------------------

nlas = normalize_height(las, tin())
plot(nlas)

gnd = filter_ground(nlas)
hist(gnd$Z, breaks = seq(-1.5,1.5,0.05))

# C. Exercise and questions
# =========================

# - Plot and compare these two normalized point-cloud. Why they look different? Fix that.

las1 = readLAS("data/MixedEucaNat.laz", filter = "-set_withheld_flag 0")
nlas1 = normalize_height(las1, tin())
nlas2 = readLAS("data/MixedEucaNat_normalized.laz", filter = "-set_withheld_flag 0")
plot(nlas1)
plot(nlas2)


# - clip a plot somewhere in MixedEucaNat.laz (the non-normalized file)
# - compute a DTM for this plot. Which method are you choosing and why?
# - compute a DSM (digital surface model)
# - normalize the plot
# - compute a CHM
# - estimate some metrics of interest in this plot with cloud_metric()
