library(lidR)
rm(list = ls(globalenv()))

# ======================================
#    DIGITAL CANOPY MODEL
# ======================================

ctg = readLAScatalog("data/Farm_A/")
col = height.colors(50)

# A. CHM using the LAScatalog engine (basic options)
# ==================================================

opt_filter(ctg) <- "-drop_withheld -drop_z_below 0"

chm = grid_canopy(ctg, 1, p2r())

plot(chm, col = col)

opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

chm = grid_canopy(ctg, 1, p2r())

plot(chm, col = col)

chm = grid_canopy(ctg, 0.5, p2r(0.1))

plot(chm, col = col)

writeRaster(chm, "data/output/CHM_res_0.5.tiff")


# B. CHM using the LAScatalog engine (advanced options)
# ==================================================

ctg = readLAScatalog("data/Farm_A/")
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

# 1. Files are too big to be loaded in R? Reduce chunk size
# ----------------------------------------------------------

opt_chunk_size(ctg) <- 80

summary(ctg)

chm = grid_canopy(ctg, 1, p2r())

plot(chm, col = col)

# 2. With a lot of memory we can compute faster
# ---------------------------------------------

opt_chunk_size(ctg) <- 200

chm = grid_canopy(ctg, 1, p2r())

plot(chm, col = col)

# 3. The output is too big to be returned in R
# ---------------------------------------------

opt_chunk_size(ctg) <- 0
opt_output_files(ctg) <- "data/output/CHM/CHM_{XLEFT}_{YBOTTOM}_{ORIGINALFILENAME}"

summary(ctg)

chm = grid_canopy(ctg, 1, p2r())

chm
inMemory(chm)
pryr::object_size(chm)

plot(chm, col = col)

p = raster::raster("data/output/CHM/CHM_207760_7357280_PRJ_A_207760_7357280_g_c_d_n_u.tif")
plot(p, col = col)


# D. Benchmark & point indexation
# =========================================

ctg = catalog("data/Farm_A/")
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"

# Using laz + lax files
system.time(grid_canopy(ctg, 1, p2r()))       # 20 sec

# Using laz files only (removing lax file)
system.time(grid_canopy(ctg, 1, p2r()))       # 40 sec

# Use las + laz files
ctg = readLAScatalog("data/las/Farm_A/")
opt_filter(ctg) <- "-drop_withheld -drop_z_below 0 -drop_z_above 40"
plot(ctg)
system.time(grid_canopy(ctg, 1, p2r()))       # 7 sec
