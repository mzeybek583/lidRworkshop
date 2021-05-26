options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)

# ======================================
#         AREA BASED APPROACH
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz", select = "*",  filter = "-set_withheld_flag 0")
col = height.colors(50)

# A. Basic usage
# =================

# Mean height of points within 10x10 m pixels

hmean = grid_metrics(las, ~mean(Z), 10)
hmean
plot(hmean, col = col)

# Max height of points within 10x10 m pixels

hmax = grid_metrics(las, ~max(Z), 10)
hmax
plot(hmax, col = col)

# We can compute several metrics at once using a list

metrics = grid_metrics(las, ~list(hmax = max(Z), hmean = mean(Z)), 10)
metrics
plot(metrics, col = col)

# For simplicity lidR proposes some sets of metrics

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

# C. Exercises and questions
# ===========================

# 1. Assuming the biomass is predicted by this equation <B = 0.5 * mean Z + 0.9 * 90th percentile of Z>
#    applied on first returns only, map the biomass on this tiny file

# 2. Map the density of ground returns with grid_metric() with a resolution of 5 meters

# 3. Map the pixel that are flat (roads) using 'stdshapemetrics'



