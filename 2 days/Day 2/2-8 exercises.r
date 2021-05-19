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

ctg = readLAScatalog("data/Farm_A_plots/")
shp = shapefile("data/shapefiles/Farm_A_plot.shp")
las = readLAS(ctg$filename[1])


# ======================================
#  An ABA/ITD mixed mapping
# ======================================

# The previous function was relatively easy to compute on 400 m2 files. It is more difficult to apply
# it continuously on a wall-to-wall catalog. To understand why you will modify the previous function
# to map the same metrics on a raster with of resolution 20 m.

ctg = catalog("data/Farm_A/")
las = readLAS(ctg$filename[1], filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")



