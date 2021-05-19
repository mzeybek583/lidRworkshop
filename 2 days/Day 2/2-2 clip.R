library(lidR)
rm(list = ls(globalenv()))

# ======================================
#    SELECTION OF REGIONS OF INTEREST
# ======================================

ctg = readLAScatalog("data/Farm_A/")

# A. Select simple geometries
# =============================

x = 207830
y = 7357410

plot(ctg)
points(x,y)

subset = clip_circle(ctg, x, y, 30)

plot(subset)

subset2 = clip_rectangle(ctg, x, y, x + 50, y + 60)

plot(subset2)

x = c(207846, 208131, 208010, 207852)
y = c(7357315, 7357537, 7357372, 7357548)

plot(ctg)
points(x,y)

subsets1 = clip_circle(ctg, x, y, 30)

plot(subsets1[[1]])
plot(subsets1[[3]])

las_check(subsets1[[1]])
las_check(subsets1[[3]])

# B. Introduction to the catalog processing engine
# ============================================

?clip_roi

# 1. Propagate the filter option to readLAS
# -----------------------------------------

opt_filter(ctg) <- "-drop_withheld"

subsets1 = clip_circle(ctg, x, y, 30)

las_check(subsets1[[1]])
las_check(subsets1[[3]])

# 2. Propagate the select option to readLAS
# -----------------------------------------

opt_select(ctg) <- "xyz"

subsets1 = clip_circle(ctg, x, y, 30)

subsets1[[1]]

# 3. Use multicore
# -----------------------------------------

library(future)
plan(multisession)

subsets1 = clip_circle(ctg, x, y, 30)

plan(sequential)

# 4. Look at current options
# -----------------------------------------

summary(ctg)

# 5. Do not return the output to R
# ----------------------------------------

opt_output_files(ctg) <- "data/output/test_lasclip1/plot_{ID}"

summary(ctg)

subsets1 = clip_circle(ctg, x, y, 30)

subsets1

plot(subsets1)

las = readLAS(subsets1$filename[2])

# lidar data do not match with satellite data (probably different times)
plot(las)

# D. Extraction of complex geometries
# ====================================

ctg      = readLAScatalog("data/Farm_A/")
planting = shapefile("data/shapefiles/Farm_A.shp")

plot(planting)
plot(ctg, map = F, add = T)

# 1. clip from the shapefile and return the output in R (not recommended)
# ---------------------------------------------------

# Do not run this snipets, it will load 1 GB of data in memory

las_planting = clip_roi(ctg, planting)
las_planting = Filter(Negate(is.empty), las_planting)

plot(las_planting[[2]])

# 2. clip from the shapefile and write in files (recommended)
# ---------------------------------------------------

opt_output_files(ctg) <- "data/output/test_lasclip2/{OBJECTID}_{SUBTALHAO}_{FAZENDA}"
opt_laz_compression(ctg) <- TRUE

summary(ctg)

library(future)
plan(multisession)

new_ctg = clip_roi(ctg, planting) # a bit long computation

plan(sequential)

plot(new_ctg)

new_ctg$filename

las = readLAS(new_ctg$filename[3], select = "xyz")
plot(las)

# E. Exercise: extract a ground inventory
# ========================================

# The shapefile in data/shapefiles/ named ground_inventories.shp contains centers of plots
# Extract each plot with a radius of 20 m

ctg = catalog("data/Farm_A/")
plot_centers = shapefile("data/shapefiles/ground_inventories.shp")
