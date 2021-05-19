# - Map the point density of the coverage

ctg = readLAScatalog("data/Farm_A/", filter = "-drop_withheld -drop_z_below 0 -drop_z_above 40")
D1 = grid_density(ctg, 4)
plot(D1, col = heat.colors(50))

# - Create a new dataset with an homogeneous density of 10 pts/m2
#   This exercise is more complex because it involves options not seen yet.
#   -> opt_output_file to redirect the output to files
#   -> templates to name the files
#   Try what is coming to your mind and read the documentation carefully when you
#   receive an error

newctg = decimate_points(ctg, homogenize(10, 5))
#>  Erreur : This function requires that the LAScatalog provides an output file template.

opt_output_files(ctg) <- "{tempdir()}/{ORIGINALFILENAME}"
newctg = decimate_points(ctg, homogenize(10, 5))

# - Map the point density of this new dataset

opt_output_files(newctg) <- ""
D2 = grid_density(newctg, 4)
plot(D2, col = heat.colors(50))

# - Read the whole decimated point cloud

las = readLAS(newctg)
plot(las)

# - Study the function catalog_retile() and find the parameters to merge the dataset
#   into bigger tiles of 280 x 280 m

opt_chunk_size(ctg) <- 280
opt_chunk_buffer(ctg) <- 0
opt_chunk_alignment(ctg) <- c(min(ctg$Min.X), min(ctg$Min.Y))
plot(ctg, chunk = T)

opt_output_files(ctg) <- "{tempdir()}/PRJ_A_{XLEFT}_{YBOTTOM}"
newctg = catalog_retile(ctg)
plot(newctg)
