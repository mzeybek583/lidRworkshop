library(lidR)
rm(list = ls(globalenv()))

# ======================================
#    DIGITAL CANOPY MODEL
# ======================================

# The original dataset has a too high point density and provides too good output for the purpose
# of this example. I use the filter -keep_random_fraction to purposly degrade the output

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_random_fraction 0.4")
col = height.colors(50)

plot(las)

# A. Many algorithm available
# ===============================

# Point to raster method
chm = grid_canopy(las, 1, p2r())
plot(chm, col = col)

chm = grid_canopy(las, 0.5, p2r())
plot(chm, col = col)

# The option subcircle turns each point into a disc of 8 points with a radius r
chm = grid_canopy(las, 0.5, p2r(0.15))
plot(chm, col = col)

# Pitfree methods
thresholds = c(0,5,10,20,25, 30)
max_edge = c(0, 1.35)
chm = grid_canopy(las, 0.5, pitfree(thresholds, max_edge))
plot(chm, col = col)

# On another example
LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
las <- readLAS(LASfile)

chm = grid_canopy(las, 0.8, p2r(0.15))
plot(chm, col = col)

chm <- grid_canopy(las, res = 0.8, pitfree(c(0,2,5,10,15), c(0, 2), 0.15))
plot(chm, col = col)

# ======================================
#    DIGITAL TERRAIN MODEL
# ======================================

las = readLAS("data/MixedEucaNat.laz")
col = gray.colors(50, 0, 1)

plot(las)
plot(las, color = "Classification")

dtm = grid_terrain(las, 1, tin())

plot(dtm, col = col)
plot_dtm3d(dtm)

x = plot(las)
add_dtm3d(x, dtm)

dtm = grid_terrain(las, 1, knnidw())
plot(dtm, col = col)
plot_dtm3d(dtm)

# ======================================
#         AREA BASED APPROACH
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz")
col = height.colors(50)

# A. Basic usage
# =================

# Mean height of points within 10x10 m pixel

hmean = grid_metrics(las, ~mean(Z), 10)
hmean
plot(hmean, col = col)

# Max height of points within 10x10 m pixel

hmax = grid_metrics(las, ~max(Z), 10)
hmax
plot(hmax, col = col)

# Obviously we can compute several metrics at once

metrics = grid_metrics(las, ~list(hmax = max(Z), hmean = mean(Z)), 10)
metrics
plot(metrics, col = col)

# For simplicity lidR proposes a set of metrics

metrics = grid_metrics(las, .stdmetrics_z, 10)
metrics
plot(metrics, col = col)

plot(metrics, "zsd", col = col)

?.stdmetrics

# B. Advanced usage with user defined metrics
# ===========================================

# The strength of the function is the ability to map almost everything

f = function(x, weight) { sum(x*weight)/sum(weight) }

X = grid_metrics(las, ~f(Z, Intensity), 10)

plot(X, col = col)
