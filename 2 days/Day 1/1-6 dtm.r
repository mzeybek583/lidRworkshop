library(lidR)
rm(list = ls(globalenv()))

# ======================================
#         DIGITAL TERRAIN MODEL
# ======================================

las = readLAS("data/MixedEucaNat.laz")
col = height.colors(50)

plot(las)
plot(las, color = "Classification")

dtm = grid_terrain(las, 1, tin())

plot(dtm)
plot_dtm3d(dtm)

x = plot(las)
add_dtm3d(x, dtm)

dtm = grid_terrain(las, 1, knnidw())
plot(dtm)
plot_dtm3d(dtm)

