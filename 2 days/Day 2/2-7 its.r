library(lidR)
rm(list = ls(globalenv()))

# ======================================
#    INDIVIDUAL TREE DETECTION
# ======================================

ctg = readLAScatalog("data/Farm_A/")

opt_select(ctg) <- "xyz"
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

col = height.colors(50)

chm = grid_canopy(ctg, 0.5, p2r())

plot(chm, col = col)

ttops = find_trees(chm, lmf(3))

plot(crop(chm, extent(chm) - 500), col = col)
plot(crop(ttops, extent(ttops) - 500), add = T)

tree = function(cluster, ws = 3, res2 = 0.5)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  las   <- filter_surfacepoints(las, res2)
  ttops <- find_trees(las, lmf(ws))
  ttops <- raster::crop(ttops, extent(cluster))
  return(ttops)
}

opt_select(ctg) <- "xyz"
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
opt_chunk_buffer(ctg) <- 15
opt_chunk_size(ctg) <- 0

output <- catalog_sapply(ctg, tree, ws = 3, res2 = 0.5) #~40 sec

plot(output, add = T)

rgdal::writeOGR(ttops, "data/output/", "ttops.shp", driver = "ESRI Shapefile")
writeRaster(chm, "data/output/chm.tif")
