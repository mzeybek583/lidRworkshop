options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)

# ======================================
#    DIGITAL CANOPY MODEL
# ======================================

# The original dataset has a too high point density and provides too good output for the purpose
# of this example. I use the filter -keep_random_fraction to purposely degrade the output

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_random_fraction 0.4 -set_withheld_flag 0")
col = height.colors(50)

las # ~10 pts/m2 instead of 24
plot(las)

# A. Point-to-raster based method
# ===============================

# Simple method that attributes the elevation of the highest point to each pixel
chm = grid_canopy(las, 2, p2r())
plot(chm, col = col)

# Is strictly equivalent to
chm = grid_metrics(las, ~max(Z), 2)
plot(chm, col = col)

# But optimized
microbenchmark::microbenchmark(canopy = grid_canopy(las, 1, p2r()),
                               metrics = grid_metrics(las, ~max(Z), 1),
                               times = 10)

# Better resolution implies few empty pixels
chm = grid_canopy(las, 1, p2r())
plot(chm, col = col)

chm = grid_canopy(las, 0.5, p2r())
plot(chm, col = col)

# The option subcircle turns each point into a disc of 8 points with a radius r
chm = grid_canopy(las, 0.5, p2r(0.15))
plot(chm, col = col)

# We can increase the radius but it does not necessarily have any meaning
chm = grid_canopy(las, 0.5, p2r(0.8))
plot(chm, col = col)

# We can fill empty pixels
chm = grid_canopy(las, 0.5, p2r(0.15, na.fill = tin()))
plot(chm, col = col)

# B Triangulation based methods
# ==============================

# Triangluation of first returns
chm = grid_canopy(las, 1, dsmtin())
plot(chm, col = col)

chm = grid_canopy(las, 0.5, dsmtin())
plot(chm, col = col)

# Khosravipour et al. pitfree algorithm
thresholds = c(0,5,10,20,25, 30)
max_edge = c(0, 1.35)
chm = grid_canopy(las, 0.5, pitfree(thresholds, max_edge))
plot(chm, col = col)

# Option subcircle
chm = grid_canopy(las, 0.5, pitfree(thresholds, max_edge, 0.1))
plot(chm, col = col)


# C. Post process
# ================

# Usually the CHM can be post-processed. Often post-processing consists in smoothing.
# lidR has no tool for that. Indeed lidR is point cloud oriented. Once you have
# a raster, it is the user responsibility to manipulate this kind of data. The user is free
# to do whatever he wants within R or within external software such as GIS tools.
#
# Here we can use the raster package and the focal function

ker <- matrix(1,3,3)
schm <- focal(chm, w = ker, fun = mean, na.rm = TRUE)
plot(schm, col = col)

# D. Questions
# ================

# No exercise. A more comprehensive exercise in next section

