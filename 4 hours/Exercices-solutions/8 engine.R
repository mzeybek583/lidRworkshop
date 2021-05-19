# - In example 2 (section B) what last line `m <- m[m$treeID %in% p$treeID,]` does?
#   Try to remove it to see what happens (use only 4 tiles to see something)
subctg = catalog_select(ctg)

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
  return(m)
}

ctg = readLAScatalog("data/Farm_A/")
opt_select(ctg) <- "xyz"
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
opt_chunk_buffer(ctg) <- 15
opt_chunk_size(ctg) <- 0
subctg = catalog_select(ctg)
options = list(automerge = TRUE)
m = catalog_apply(subctg, my_process, .options = options)

plot(m, col = rgb(0,0,1,0.3))


# The following is a simple (and a bit naive) function to remove high noise points
# - Apply this function to the whole collection  using catalog apply
filter_noise = function(las, sensitivity)
{
  p95 <- grid_metrics(las, ~quantile(Z, probs = 0.95), 10)
  las <- merge_spatial(las, p95, "p95")
  las <- filter_poi(las, Z < 1+p95*sensitivity, Z > -0.5)
  las$p95 <- NULL
  return(las)
}

filter_noise_collection = function(cl, sensitivity)
{
  las <- readLAS(cl)
  if (is.empty(las)) return(NULL)
  las <- filter_noise(las, sensitivity)
  las <- filter_poi(las, buffer == 0L)
  return(las)
}

ctg = readLAScatalog("data/Farm_A/")
opt_select(ctg) <- "*"
opt_filter(ctg) <- "-drop_withheld -drop_"
opt_output_files(ctg) <- "{tempdir()}/*"
opt_chunk_buffer(ctg) <- 20
opt_chunk_size(ctg) <- 0

options = list(automerge = TRUE)
output = catalog_apply(ctg, filter_noise_collection, sensitivity = 1.2, .options = options)

#las = readLAS(output)
#plot(las)

