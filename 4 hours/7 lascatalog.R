options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)
library(sf)

# ======================================
# LASCATALOG PROCESSING
# ======================================

# A. Basic usage
# =======================

ctg = readLAScatalog("data/Farm_A/")
ctg

plot(ctg)
plot(ctg, map = TRUE)

crs(ctg)
projection(ctg)
st_crs(ctg)

extent(ctg)
bbox(ctg)
st_bbox(ctg)

# B. LAScatalog objects validation
# ==========================================

las_check(ctg)

#  C. Clip
# ==========================================

x = c(207846, 208131, 208010, 207852, 207400)
y = c(7357315, 7357537, 7357372, 7357548, 7357900)

plot(ctg)
points(x,y)

subsets1 = clip_circle(ctg, x, y, 30)

plot(subsets1[[1]])
plot(subsets1[[3]])

las_check(subsets1[[1]])
las_check(subsets1[[3]])

#  D. CHM
# ==========================================

chm = grid_canopy(ctg, 0.5, p2r(0.15))
plot(chm, col = height.colors(50))

# Many problems here:
# 1. Warnings?
warnings()
# 2. The CHM is not nice

opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
chm = grid_canopy(ctg, 0.5, p2r(0.15))
plot(chm, col = height.colors(50))

#  E. ABA
# ==========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
model = grid_metrics(ctg, ~6*mean(Z) -2*max(Z) - 0.05*mean(Intensity) + 100, 20)
plot(model, col = height.colors(50))

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40 -keep_first"
model = grid_metrics(ctg, ~6*mean(Z) -2*max(Z) - 0.05*mean(Intensity) + 100, 20)
plot(model, col = height.colors(50))

#  F. ITD
# ==========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
ttops = find_trees(ctg, lmf(3, hmin = 5))
plot(chm, col = height.colors(50))
plot(ttops, add = T, cex = 0.1)

# G. DTM
# ==========================================

# No DTM example because the data are already normalized
# but it works the same
## DONT RUN
dtm = grid_terrain(ctg, 1, tin())
##

# G. Processing options
# =========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
opt_select(ctg) <- "xyz"
opt_chunk_size(ctg) <- 100
opt_chunk_buffer(ctg) <- 10

ttops = find_trees(ctg, lmf(3, hmin = 5))
plot(chm, col = height.colors(50))
plot(ttops, add = T, cex = 0.1)

# H. Parallel computing
# ==========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
opt_select(ctg) <- "xyz"
opt_chunk_size(ctg) <- 0
opt_chunk_buffer(ctg) <- 30

library(future)

plan(sequential)
ttops = find_trees(ctg, lmf(3, hmin = 5))

plan(multisession)
ttops = find_trees(ctg, lmf(3, hmin = 5))

## NOT RUN
plan(remote, workers = c("localhost", "bob@132.203.41.87", "alice@132.203.41.87"))
ttops = find_trees(ctg, lmf(3, hmin = 5))
##

# revert to single core
plan(sequential)

#  H. Exercises and questions
# ==========================================

# - Map the point density of the coverage

# - Create a new dataset with an homogeneous density of 10 pts/m2 with decimate_points()
#   This exercise is more complex because it involves options not seen yet.
#   -> opt_output_file to redirect the output to files
#   -> templates to name the files
#   Try what is coming to your mind and read the documentation carefully when you
#   receive an error

# - Map the point density of this new dataset

# - Read the whole decimated point-cloud which (is not that big but don't do that we regular
#   collections)

# - Study the function catalog_retile() and find the parameters to merge the dataset
#   into bigger tiles

