options("rgdal_show_exportToProj4_warnings"="none")
rm(list = ls(globalenv()))

library(lidR)


# == More help  =========================================================================
?catalog_apply
# https://jean-romain.github.io/lidRbook/engine2.html
# https://cran.r-project.org/web/packages/lidR/vignettes/lidR-catalog-apply-examples.html
# https://cran.r-project.org/web/packages/lidR/vignettes/lidR-LAScatalog-engine.html#low-level-api
# ========================================================================================


# A. Example of catalog_apply()
# =====================================

# Problem: how to apply the following on a collection?
# ---------------------------------------------------

ctg = readLAScatalog("data/Farm_A/")
las = readLAS(ctg$filename[16], filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")

surflas = filter_surfacepoints(las, 1)

plot(las)
plot(surflas)

ri = grid_metrics(las, ~rumple_index(X,Y,Z), 10)
plot(ri)

# Solution: LAScatalog processing engine
# --------------------------------------

grid_rumple_index = function(cluster, res1 = 10, res2 = 1)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  las <- filter_surfacepoints(las, res2)
  ri  <- grid_metrics(las, ~rumple_index(X,Y,Z), res1)
  ri  <- raster::crop(ri, extent(cluster))
  return(ri)
}

opt_select(ctg) <- "xyz"
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
opt_chunk_buffer(ctg) <- 0
opt_chunk_size(ctg) <- 0

options = list(automerge = TRUE, alignment = 10)
ri = catalog_apply(ctg, grid_rumple_index, res1 = 10, res2 = 0.5, .options = options)

plot(ri, col = height.colors(50))

# B. Example 2 of catalog_apply()
# =====================================

my_process = function(cl) {
  las = readLAS(cl)
  if (is.empty(las)) return(NULL)
  bbox <- extent(cl)
  las <- filter_surfacepoints(las, res = 0.5)
  chm <- grid_canopy(las, 0.5, p2r())
  ttops <- find_trees(las, lmf(3, 5))
  las <- segment_trees(las, dalponte2016(chm, ttops))
  p <- tree_metrics(las)
  p <- crop(p, bbox)
  m <- delineate_crowns(las, func = .stdtreemetrics)
  m <- m[m$treeID %in% p$treeID,]
  return(m)
}

opt_chunk_buffer(ctg) <- 15
options = list(automerge = TRUE)
m = catalog_apply(ctg, my_process, .options = options)
m
plot(m)


# C. Exercises
# ====================================

# 1. In example 2 (section B) what does last line `m <- m[m$treeID %in% p$treeID,]`?
#    Try to remove it to see what happens (use only 4 tiles to see something)
subctg = catalog_select(ctg)

# 2. The following is a simple (and a bit naive) function to remove high noise points.
#    - Explain what this function does
#    - Apply this function to the whole collection using catalog_apply()
filter_noise = function(las, sensitivity)
{
  p95 <- grid_metrics(las, ~quantile(Z, probs = 0.95), 10)
  las <- merge_spatial(las, p95, "p95")
  las <- filter_poi(las, Z < 1+p95*sensitivity, Z > -0.5)
  las$p95 <- NULL
  return(las)
}

las = readLAS("data/Farm_A/PRJ_A_207480_7357420_g_c_d_n_u.laz")
nonoise = filter_noise(las, 1.2)


# 3. Design an application that retrieves the polygon of each flightiness (hard)
#    You can use concaveman::concaveman, sf, dplyr. Stars by designing a test function that
#    works on a LAS object and later apply on the collection. The output should look like:
flightlines = st_read("data/flightlines.shp")
plot(flightlines, col = sf.colors(6, alpha = 0.5))
plot(flightlines[3,])



