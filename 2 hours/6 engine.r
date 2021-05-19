library(lidR)
rm(list = ls(globalenv()))

?catalog_apply


# A. Example of catalog apply
# =====================================

# Problem
# --------------------

ctg = readLAScatalog("data/Farm_A/")

las = readLAS(ctg$filename[16], filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")

surflas = lasfiltersurfacepoints(las, 0.5)

plot(las)
plot(surflas)

ri = grid_metrics(las, rumple_index(X,Y,Z), 10)
plot(ri)

# Solution
# ------------------

grid_rumple_index = function(cluster, res1 = 10, res2 = 0.5)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  las <- lasfiltersurfacepoints(las, res2)
  ri  <- grid_metrics(las, rumple_index(X,Y,Z), res1)
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

# B. Example 2 of catalog apply
# =====================================

my_process = function(cl) {
  las = readLAS(cl)
  if (is.empty(las)) return(NULL)
  bbox = extent(cl)
  las = lasfilterduplicates(las)
  chm = grid_canopy(las, 0.5, p2r())
  ttops = tree_detection(las, lmf(3, 5))
  las = lastrees(las, dalponte2016(chm, ttops))
  p = tree_metrics(las)
  p = crop(p, bbox)
  m = tree_hulls(las, func = .stdtreemetrics)
  m = m[m$treeID %in% p$treeID,]
  return(m)
}

opt_chunk_buffer(ctg) <- 15
options = list(automerge = TRUE)
m = catalog_apply(ctg, my_process, .options = options)
m
plot(m)

shapefile(m, paste0(tempdir(), "/tree_hull_demo.shp"))
