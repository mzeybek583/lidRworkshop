library(lidR)
rm(list = ls(globalenv()))

# ======================================
#         Noise filtering
# ======================================

# lidR does not have a noise filter function. So far we used simple threshold to remove oulier below 0
# and above 40. That was good enough because we are lucky. Outlier were strongly above the trees and
# the trees were all the same size (plantation). In a more complex context we can have low height outliers
# that are in an area with small trees surrounded by big trees. A threshold cannot help in this context.
#
# The objective of this exercise is to develop a relatively simple but more advanced outlier removal
# function using lidR available tools.
#
# 1. Create your own noise filter function based on simple ideas (call it lasfilternoise)
# 2. Test it on a file that has outliers
# 3. Extend this function to make it applicable over an entire catalog

las = readLAS("data/Farm_A/PRJ_A_207620_7357560_g_c_d_n_u.laz")
plot(las)

lasfilternoise = function(las, tol, res)
{
  dsm = grid_canopy(las, res, p2r())
  ker = matrix(1,3,3)
  dsm = raster::focal(dsm, w = ker, fun = median, na.rm = TRUE)
  las = lasmergespatial(las, dsm, "Zdsm")
  las = lasfilter(las, Z >= 0, Z < Zdsm + tol)
  return(las)
}

las = lasfilternoise(las, tol = 1.1, res = 10)
plot(las)

lasdenoiser = function(las, tolerance, res)
{
  las = readLAS(las)
  if (is.empty(las)) return(NULL)

  las = lasfilternoise(las, tolerance, res)
  las = lasfilter(las, buffer == 0)
  return(las)
}

ctg = catalog("data/Farm_A/")

opt_filter(ctg) <- "-drop_withheld -drop_z_below 0"
opt_chunk_buffer(ctg) = 10
opt_chunk_size(ctg) = 0
opt_output_files(ctg) <- "data/output/denoised/{ORIGINALFILENAME}_denoised"

output = catalog_apply(ctg, lasdenoiser, tolerance = 1.1, res = 10)
output = unlist(output)
new_ctg = catalog(output)

plot(new_ctg)

spplot(ctg, c("Min.Z", "Max.Z"))
spplot(new_ctg, c("Min.Z", "Max.Z"))

# ======================================
#  An ABA/ITS mixed predictive model
# ======================================

# We usually use simple statistics such as mean, sd, max, quantile of Z elevations from the point
# cloud to build a predictive model such as biomass = a*mean(Z) + b*max(Z) + c*sd(Z). I would like to
# study if we could improve such simple model types by integrating metrics derived from single tree
# detection such as the number of trees. To do that we have:
#
#  - A shapefile Farm_A_plots.shp that contains ground truth inventories (plots)
#  - Corresponding laz files with 400 m2 plots
#
# You mission is to
#
#  1. Create a function that computes, on a single file, some simple metrics derived from Z such as
#     mean(Z), max(Z) + metrics derived from individual tree detection such as the number of trees
#     or the mean elevation of the trees.
#  2. Apply this function on all the files to get the metrics of each plot
#  3. Create a predictive model that links VCSC, to the predictive metrics derived from the point cloud.

ctg = catalog("data/Farm_A_plots/")
shp = shapefile("data/shapefiles/Farm_A_plot.shp")
las = readLAS(ctg$filename[1])

plot(ctg, map = F)
plot(shp, add = T)
spplot(shp, "VCSC")
plot(las)

my_metrics = function(las, res)
{
  las2   = lasfiltersurfacepoints(las, res)

  ttops  = tree_detection(las2, lmf(3))
  ntree  = nrow(ttops)
  ztree  = mean(ttops$Z)
  sdtree = sd(ttops$Z)
  ri     = rumple_index(las2$X,las2$Y,las2$Z)
  zmean  = mean(las$Z)
  zsd    = sd(las$Z)

  output = list(ntree = ntree,
                ztree = ztree,
                sdtree = sdtree,
                rumple = ri,
                zmean = zmean,
                zsd = zsd)

  return(output)
}

m = my_metrics(las, res = 1)


my_metrics_apply = function(cluster, res)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  metrics = my_metrics(las, res)
  return(metrics)
}

opt_cores(ctg) = 4
opt_chunk_buffer(ctg) = 0
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

metrics = catalog_apply(ctg, my_metrics_apply, res = 0.5)

library(dplyr)
library(ggplot2)

metrics = bind_rows(metrics)
metrics = mutate(metrics, CHAVE2 = tools::file_path_sans_ext(basename(ctg$filename)))
metrics = left_join(metrics, shp@data)

ggplot(metrics) + aes(y = VCSC, x = rumple) + geom_point() + theme_light()
ggplot(metrics) + aes(y = VCSC, x = zmean) + geom_point() + theme_light()
ggplot(metrics) + aes(y = VCSC, x = zsd) + geom_point() + theme_light()
ggplot(metrics) + aes(y = VCSC, x = ntree) + geom_point() + theme_light()
ggplot(metrics) + aes(y = VCSC, x = ztree) + geom_point() + theme_light()
ggplot(metrics) + aes(y = VCSC, x = sdtree) + geom_point() + theme_light()
ggplot(metrics) + aes(y = zsd, x = ztree) + geom_point() + theme_light()

model = lm(VCSC ~ zsd + zmean + 0, data = metrics)
prediction = predict(model, metrics)
metrics$VCSC_pred = prediction

ggplot(metrics) + aes(y = VCSC_pred, x = VCSC) + geom_point() + theme_light() + geom_abline(slope = 1) + coord_equal() + xlim(0,350) + ylim(0,350)

model = lm(VCSC ~ zsd + zmean + ztree + 0, data = metrics)
prediction = predict(model, metrics)
metrics$VCSC_pred = prediction

ggplot(metrics) + aes(y = VCSC_pred, x = VCSC) + geom_point() + theme_light() + geom_abline(slope = 1) + coord_equal() + xlim(0,350) + ylim(0,350)


# ======================================
#  An ABA/ITD mixed mapping
# ======================================

# The previous function was relatively easy to compute on 400 m2 files. It is more difficult to apply
# it continuously on a wall-to-wall catalog. To understand why you will modify the previous function
# to map the same metrics on a raster with of resolution 20 m.

ctg = catalog("data/Farm_A/")
las = readLAS(ctg$filename[1], filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")


my_analyse = function(las)
{
  # Simple metrics
  metrics = grid_metrics(las, list(zmean = mean(Z), zsd = sd(Z)), 20)

  # Rumple index
  las2   = lasfiltersurfacepoints(las, 0.5)
  rumple = grid_metrics(las2, list(rumple = rumple_index(X,Y,Z)), 20)

  # Trees metrics
  ttops  = tree_detection(las2, lmf(3))
  ntree  = raster::rasterize(ttops, metrics, field = "Z", fun = function(x, ...) c(length(x), mean(x), sd(x)))
  ntree[is.na(ntree)] = 0

  # Merge the rasters
  output = raster::stack(metrics, rumple, ntree)
  names(output) <- c("zmean", "zsd", "rumple", "ntrees", "ztree", "sdtree")

  return(output)
}

r = my_analyse(las)
plot(r)

my_analyse_apply = function(cluster)
{
  las = readLAS(cluster)
  if (is.empty(las)) return(NULL)

  output = my_analyse(las)
  output = crop(output, cluster)
  return(output)
}

opt_cores(ctg) = 2
opt_chunk_buffer(ctg) = 20
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

metrics = catalog_apply(ctg, my_analyse_apply, check_alignment = 20)
n = names(metrics[[1]])
metrics = do.call(raster::merge, metrics)
names(metrics) <- n

plot(metrics, col = height.colors(50))


