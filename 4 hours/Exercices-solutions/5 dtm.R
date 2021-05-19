# - Plot and compare these two normalized point-cloud. Why they look different? Fix that.

# Some non ground points are below 0. It can be slightly low noise point not classified as
# ground by the data provider. This low points not being numerous and dark blue we hardly
# see them

las1 = readLAS("data/MixedEucaNat.laz", filter = "-set_withheld_flag 0")
nlas1 = normalize_height(las1, tin())
nlas2 = readLAS("data/MixedEucaNat_normalized.laz", filter = "-set_withheld_flag 0")
plot(nlas1)
plot(nlas2)

nlas1 = filter_poi(nlas1, Z > -0.1)
plot(nlas1)

# - clip a plot somewhere in MixedEucaNat.laz (the non-normalized file)

circ <- clip_circle(las, 203930, 7359000, 25)
plot(circ)

# - compute a DTM for this plot. Which method are you choosing and why?

dtm <- grid_terrain(circ, 0.5, kriging())
plot_dtm3d(dtm)

# - compute a DSM (digital surface model)

dsm <- grid_canopy(circ, 1, p2r(0.1))
plot(dsm, col = height.colors(50))

# - normalize the plot

ncirc = circ - dtm
plot(ncirc)

# - compute a CHM

chm <- grid_canopy(ncirc, 1, p2r(0.1))
plot(chm, col = height.colors(50))

# - estimate some metrics of interest in this plot with cloud_metric()

metrics = cloud_metrics(ncirc, .stdmetrics_z)
metrics
