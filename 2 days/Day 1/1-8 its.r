library(lidR)
rm(list = ls(globalenv()))

# ======================================
#      INDIVIDUAL TREE SEGMENTATION
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz")
col1 = height.colors(50)
col2 = pastel.colors(900)

# A. CHM based methods
# ====================

# 1.Build a CHM
# --------------

chm = grid_canopy(las, 0.5, p2r(0.15))
plot(chm, col = col1)

# 2. OptionalLly smooth the CHM
# ----------------------------

kernel = matrix(1,3,3)
schm = raster::focal(chm, w = kernel, fun = median, na.rm = TRUE)

plot(schm, col = height.colors(30))

# 3. Tree detection
# ------------------

ttops = find_trees(schm, lmf(2.5))

plot(chm, col = col1)
plot(ttops, col = "black", add = T)

# 4. Segmentation
# -----------------

las = segment_trees(las, dalponte2016(schm, ttops))

plot(las, color = "treeID", colorPalette = col2)

tree25 = filter_poi(las, treeID == 25)
tree125 = filter_poi(las, treeID == 125)

plot(tree25)
plot(tree125)

# 5. Working with raster
# --------------------------------

# As said previously lidR deals with point clouds. This is why we used segment_trees()
# But with a CHM the original point-cloud is not strictly required.

trees = dalponte2016(chm = chm, treetops = ttops)()

plot(trees, col = col2)
plot(ttops, add = TRUE)

# B. Point cloud based methods (No CHM)
# =====================================

# 1. Tree detection
# ------------------

ttops = find_trees(las, lmf(3, hmin = 5))


x = plot(las)
add_treetops3d(x, ttops)

# 2. What can be done on a raster can be done on a point cloud
# ------------------------------------------------------------

lassp = filter_surfacepoints(las, 0.5)
slassp = smooth_height(lassp, 1.5)
plot(slassp)

ttops = tree_detection(slassp, lmf(3))

x = plot(las)
add_treetops3d(x, ttops)

# 3. Tree segmentation
# --------------------

las = segment_trees(las, li2012())

plot(las, color = "treeID", colorPalette = col2)

# This algorithm does not seem pertinent for such a dataset.

# C. Extraction of metrics
# ==========================

ttops = tree_detection(schm, lmf(2.5))
las = segment_trees(las, dalponte2016(schm, ttops))

plot(las, color = "treeID", colorPalette = col2)

# 1. tree_metrics works like grid_metrics
# ----------------------------------------

metrics = tree_metrics(las, list(n = length(Z)))
metrics
spplot(metrics, "n")

# 2. It maps any user's function at the tree level
# -----------------------------------------------

f = function(x, y)
{
  ch <- chull(x,y)
  ch <- c(ch, ch[1])
  coords <- data.frame(x = x[ch], y = y[ch])
  p  = sp::Polygon(coords)
  area = p@area

  return(list(A = area))
}

metrics = tree_metrics(las, f(X,Y))
metrics
spplot(metrics, "A")

# 3. Some metrics are already recorded
# ------------------------------------

metrics = tree_metrics(las, .stdtreemetrics)
metrics

# 4. tree_hull give several kinds of tree hull
# -------------------------------------------

# convex hull

cvx_hulls = delineate_crowns(las)
cvx_hulls

plot(cvx_hulls)
plot(ttops, add = TRUE)

cvx_hulls = delineate_crowns(las, func = .stdtreemetrics)
spplot(cvx_hulls, "convhull_area")

# concave hulls (long computation)

ccv_hulls = delineate_crowns(las, type = "concave")
spplot(ccv_hulls, "ZTOP")
