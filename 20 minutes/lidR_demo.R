library(lidR)
library(magrittr)
rgdal::set_thin_PROJ6_warnings(TRUE)

hc = height.colors(50)

# =========================
# ==== Read lidar data ====
#==========================

las = readLAS("data/MixedEucaNat_normalized.laz")
print(las)
plot(las)
plot(las, color = "Intensity", trim = 800)

las_check(las)

# ==============================
# ==== Canopy height models ====
# ==============================

chm = grid_canopy(las, 1, p2r())
plot(chm, col = hc)

chm2 = grid_canopy(las, 0.5, p2r(0.2))
plot(chm2, col = hc)

chm3 = grid_canopy(las, 0.25, p2r(0.2))
plot(chm3, col = hc)

chm4 = grid_canopy(las, 0.25, pitfree(c(0,2,5,10,15), c(0,1), subcircle = 0.2))
plot(chm4, col = hc)

# ============================
# === Area Based Approach ====
# ============================

las = readLAS("data/CN_681_5015.laz")
plot(las)

# ---- Compute any metric ----

m1 <- grid_metrics(las, ~mean(Z), 10)
m1
plot(m1, col = hc)

m2 <- grid_metrics(las, ~list(Zavg = mean(Z), Iavg = mean(Intensity)))
m2
plot(m2, col = hc)

# ---- Real applications ----

biomass = grid_metrics(las, ~list(biomass = 2*mean(Z) + 0.5*quantile(Z, 0.9) + 0.01*median(Intensity)), 10)
plot(biomass, col = viridis::viridis(50), main = "Biomass")

# ---- Large covergage ----

ctg = readLAScatalog("/media/jr/Seagate Expansion Drive/ALS data/Haliburton dataset/Landscape LiDAR/")
plot(ctg)

ref <- raster(xmn = 690000, ymn = 5015000, xmx = 693000, ymx = 5018000)
res(ref) <- 20
plot(extent(ref), add = T, col = "red", lwd = 5)

biomass = grid_metrics(ctg, ~list(biomass = 2*mean(Z) + 0.5*quantile(Z, 0.9) + 0.01*median(Intensity)), ref)
plot(biomass, col = viridis::viridis(50), main = "Biomass")

plot(ctg)
plot(biomass, col = viridis::viridis(50), add = TRUE)

# ===============================
# ==== Digital Terrain Model ====
# ===============================

LASfile <- system.file("extdata", "Topography.laz", package="lidR")
las <- readLAS(LASfile, select = "xyzrn")
plot(las)

las <- classify_ground(las, csf())
plot(las, color = "Classification")

dtm <- grid_terrain(las, 1, tin())
dtm
plot(dtm, col = gray.colors(50,0,1))

# ---- Large coverage ----

ctg = readLAScatalog("/media/jr/Seagate Expansion Drive/Quebec/Montmorency/las/")
opt_chunk_size(ctg) <- 700
opt_chunk_alignment(ctg) <- c(339000, 5240000)
ref <- raster(xmn = 339000, ymn = 5240000, xmx = 341000, ymx = 5242000)
res(ref) <- 2
plot(ctg)
plot(extent(ref), add = T, col = "red", lwd = 5)

library(future)
plan(multisession, workers = 2)
dtm = grid_terrain(ctg, ref, tin())

plot(dtm, col = gray.colors(50, 0, 1))

plot(ctg)
plot(dtm, col = gray.colors(50, 0, 1), add = TRUE)

# ---- shaded DTM ----

shade = function(dtm)
{
  mdtm = t(as.matrix(dtm))
  shadeddtm = rayshader::sphere_shade(mdtm, texture = "bw")
  dtm[] = (shadeddtm[,,1] + shadeddtm[,,2] + shadeddtm[,,3]) / 3
  dtm
}

sdtm = shade(dtm)
plot(sdtm, col = gray.colors(50, 0, 1))

# ==========================
# ==== Plot extraction =====
# ==========================

ctg = readLAScatalog("/media/jr/Seagate Expansion Drive/ALS data/Haliburton dataset/Landscape LiDAR/")
ctg
plot(ctg)

p = shapefile("data/lidR_demo_points.shp")
p

plot(ctg)
plot(p, add = T, col = "red", pch = 8)

las = clip_roi(ctg, p, radius = 30)

plot(las[[1]])
plot(las[[2]])

m = lapply(las, cloud_metrics, func = ~list(Zavg = mean(Z), Iavg = mean(Intensity)))
m = data.table::rbindlist(m)
m

# =================================
# ==== Forest units extraction ====
# =================================

p = shapefile("data/lidR_demo_polygon.shp")
p

plot(ctg)
plot(p, add = T, col = "red")

las = clip_roi(ctg, p)
plot(las)

# ==============================================
# ==== Example of research and development =====
# ==============================================

LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
las = readLAS(LASfile)
plot(las)

m1 <- point_metrics(las, ~mean(Intensity), k = 8)
las@data$Iavg = m1$V1
plot(las, color = "Iavg", trim = 80)

# ---- Real applications ----

# Classification of water points
lake_detection = function(x,y,z, th1 = 25, th2 = 6) {
  xyz <- cbind(x,y,z)
  eigen_m <- lidR:::fast_eigen_values(xyz)$eigen
  is_planar <- eigen_m[2] > (th1*eigen_m[3]) && (th2*eigen_m[2]) > eigen_m[1]
  return(list(planar = is_planar))
}

M <- point_metrics(las, ~lake_detection(X,Y,Z), k = 10)
las@data[Z > 0.1, Classification := 4L]
las@data[M$planar, Classification := 9L]
plot(las, color = "Classification")

# -->> look in GIS

# ===================================
# ==== Individual tree detection ====
# ===================================

las <- readLAS("/media/jr/Seagate Expansion Drive/ALS data/Fichiers las divers/Example.las")
las <- classify_ground(las, csf(), last_returns = FALSE)
las <- normalize_height(las, tin())
plot(las)

ttops <- find_trees(las, lmf(5, 5))
ttops

plot(las) %>% add_treetops3d(ttops)

algo <- pitfree(thresholds = c(0,10,20,30,40,50), subcircle = 0.2)
ker <- matrix(1,3,3)
chm1 <- grid_canopy(las, 0.5, algo)
chm1 <- focal(chm1, w = ker, fun = median)

ttops1 <- find_trees(chm1, lmf(5,5))

plot(chm1, col = hc)
plot(ttops1, add = T)

# ---- large coverage -----

ctg <- readLAScatalog("data/Farm_A/")
ctg
plot(ctg)
opt_filter(ctg) <- "-drop_withheld -drop_z_above 40"

# ---- Canopy height models ----
chm = grid_canopy(ctg, 0.5, p2r())
plot(chm, col = hc, add = T)

# ---- Individual tree detection ----
ttops = find_trees(ctg, lmf(3, 5))

plot(chm, col = hc)
plot(ttops, add = T, cex = 0.1)

# ---- Moving to a GIS ----
writeRaster(chm, "~/Documents/lidR demo/CHM.tiff")
shapefile(ttops, "~/Documents/lidR demo/ttops.shp")

# ======================================
# ==== Individual tree segmentation ====
# ======================================

plot(las)

las = segment_trees(las, li2012())
plot(las, color = "treeID")

algo = dalponte2016(chm1, ttops1, max_cr = 30, th_cr = .1)
las = segment_trees(las, algo)
plot(las, color = "treeID")

tree145 = filter_poi(las, treeID == 145)
plot(tree145, size = 3)

trees = algo()
plot(trees, col = pastel.colors(200))
plot(ttops1, add = T)

# =================================
# ==== Individual tree metrics ====
# =================================

m <- tree_metrics(las, .stdtreemetrics)
m
spplot(m, "Z")
spplot(m, "npoints")

m <- tree_hulls(las, func = .stdtreemetrics)
m
spplot(m, "Z")
spplot(m, "npoints")

# --- large coverage ----

my_process = function(cl) {
  las = readLAS(cl)
  if (is.empty(las)) return(NULL)
  bbox = extent(cl)
  las = filter_duplicates(las)
  chm = grid_canopy(las, 0.5, p2r())
  ttops = tree_detection(las, lmf(3, 5))
  las = segment_trees(las, dalponte2016(chm, ttops))
  p = tree_metrics(las)
  p = crop(p, bbox)
  m = delineate_crowns(las, func = .stdtreemetrics)
  m = m[m$treeID %in% p$treeID,]
  return(m)
}

plot(ctg)
options = list(automerge = TRUE)
m = catalog_apply(ctg, my_process, .options = options)

plot(m)

shapefile(m, "~/Documents/lidR demo/tree_hull_demo.shp")

















# ==== Benchmarks =====

n = 5e5
X = round(runif(n, 0, 1000),3)
Y = round(runif(n, 0, 1000),3)
XY = cbind(X,Y)
XX = data.frame(X,Y)

x = runif(n, 0, 1000)
y = runif(n, 0, 1000)
xy = cbind(x,y)

# ==== KNN benchmark =====

bench::mark(
  knn1 = FNN::get.knnx(XY, xy, k = 8),
  knn2 = RANN::nn2(XY, xy, k = 10),
  knn3 = lidR:::C_knn(X,Y,x,y,10,4),
  check = FALSE, relative = TRUE)

# ==== Delaunay benchmark =====

bench::mark(
  D1 = geometry::delaunayn(XY),
  D2 = lidR:::C_delaunay(XX, c(0.001,0.001), c(0,0)),
  check = FALSE, relative = TRUE)

# ==== Multiple machines paralellisation =====

library(future)
plan(remote, workers = c("localhost", "jr@132.203.41.25", "bob@132.203.41.152", "alice@132.203.41.125"))
metrics = grid_metrics(ctg, ~mean(Z), 20)
