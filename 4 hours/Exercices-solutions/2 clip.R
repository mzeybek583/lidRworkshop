plots = shapefile("data/shapefiles/MixedEucaNatPlot.shp")
plot(las@header, map = FALSE)
plot(plots, add = TRUE)

# - clip the 5 plots with a radius of 11.3 m

inventory = clip_roi(las, plots, radius = 11.3)
plot(inventory[[1]])

# - clip a transect from A(203850, 7358950) to B(203950, 7959000)

tr <- clip_transect(las, c(203850, 7358950), c(203950, 7359000), width = 5)
plot(tr, axis = T)

# - clip a transect from A(203850, 7358950) to B(203950, 7959000) but rotate it in such a way
#   that it is no longer in the XY diagonal (convenient for plotting for example)

ptr <- clip_transect(las, c(203850, 7358950), c(203950, 7359000), width = 5, xz = TRUE)
plot(tr, axis = T)
plot(ptr, axis = T)
plot(ptr$X, ptr$Z, cex = 0.25, pch = 19, asp = 1)
