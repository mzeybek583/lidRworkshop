# E. Exercise: extract a ground inventory
# ========================================

# The shapefile in data/shapefiles/ named ground_inventories.shp contains centers of plots
# Extract each plot with a radius of 20 m

ctg = catalog("data/Farm_A/")
plot_centers = shapefile("data/shapefiles/ground_inventories.shp")

plot(ctg)
plot(plot_centers, add = T, col = "red")

summary(ctg)

lasclip(ctg, plot_centers, radius = 20)
