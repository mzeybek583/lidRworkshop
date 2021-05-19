library(lidR)
rm(list = ls(globalenv()))

# ======================================
#  READ DATA AND VISUALIZE THE CONTENT
# ======================================

# A. Basic usage
# =======================

ctg = readLAScatalog("data/Farm_A/")
ctg

plot(ctg)
plot(ctg, map = TRUE)

projection(ctg)
extent(ctg)

# B. LAScatalog objects validation
# ==========================================

las_check(ctg)

# ==========================================
#  CLIP
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

# ==========================================
#  CANOPY HEIGHT MODEL
# ==========================================

chm = grid_canopy(ctg, 0.5, p2r(0.15))
plot(chm, col = height.colors(50))

opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
chm = grid_canopy(ctg, 0.5, p2r(0.15))
plot(chm, col = height.colors(50))

# ==========================================
#  AREA BASED APPROACH
# ==========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
model = grid_metrics(ctg, ~6*mean(Z) -2*max(Z) - 0.05*mean(Intensity) + 100, 10)
plot(model, col = height.colors(50))

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40 -keep_first"
model = grid_metrics(ctg, ~6*mean(Z) -2*max(Z) - 0.05*mean(Intensity) +100, 10)
plot(model, col = height.colors(50))

# ==========================================
#  INDIVIDUAL TREE DETECTION
# ==========================================

opt_filter(ctg) <- "-drop_withheld  -drop_z_below 0 -drop_z_above 40"
ttops = find_trees(ctg, lmf(3, hmin = 5))
plot(chm, col = height.colors(50))
plot(ttops, add = T, cex = 0.1)

# ==========================================
#  PARALLEL COMPUTING
# ==========================================

library(future)

plan(sequential)
ttops = tree_detection(ctg, lmf(3, hmin = 5))

plan(multisession)
ttops = tree_detection(ctg, lmf(3, hmin = 5))

plan(remote, workers = c("localhost", "andre@132.203.41.87"))
ctg@input_options$alt_dir <- "/home/andre/Téléchargements/lidR-workshop/data/Farm_A/"
ttops = tree_detection(ctg, lmf(3, hmin = 5))
