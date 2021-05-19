library(lidR)
rm(list = ls(globalenv()))

# ======================================
#       CATALOG FUNCTIONS
# ======================================

# We have already seen the function 'catalog'. Several other catalog_* functions exist
# - catalog_retile
# - catalog_select
# - catalog_intersect
# And catalog_apply which is the most important function. It gives access to the catalog processing
# engine. Each lidR function that manipulates a LAScatalog uses internally catalog_apply. With catalog_
# apply you can build your own process

?catalog_apply


# A. Example of catalog apply
# =====================================

# Compute a rumple index for each pixel in an ABA
# - What is a rumple index? (see function rumple_index)
# - On which points does it make sense to compute a rumple index?
# - Rumple index is computationally demanding? How to compute it faster?
#
# - Load a single file, make a function that computes a pertinent RI on this single file
# - Scale up this function to apply it over the entire LAScatalog

ctg = readLAScatalog("data/Farm_A/")

las = readLAS(ctg$filename[16], filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")

las = filter_surfacepoints(las, 0.5)

plot(las)

ri = grid_metrics(las, rumple_index(X,Y,Z), 10)

plot(ri)

grid_rumple_index = function(las, res1 = 10, res2 = 0.5)
{
  las = filter_surfacepoints(las, res2)
  ri = grid_metrics(las, rumple_index(X,Y,Z), res1)
  return(ri)
}

ri = grid_rumple_index(las)
plot(ri, col = height.colors(50))


grid_rumple_index = function(cluster, res1 = 10, res2 = 0.5)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  las <- filter_surfacepoints(las, res2)
  ri  <- grid_metrics(las, rumple_index(X,Y,Z), res1)
  ri  <- raster::crop(ri, extent(cluster))
  return(ri)
}

opt_select(ctg) <- "xyz"
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
opt_chunk_buffer(ctg) <- 15
opt_chunk_size(ctg) <- 0

output = catalog_sapply(ctg, grid_rumple_index, res1 = 20, res2 = 0.5)

plot(output, col = height.colors(50))
