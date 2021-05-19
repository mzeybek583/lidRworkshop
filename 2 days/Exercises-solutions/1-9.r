# ======================================
#              EXERCISES
# ======================================

# Read the file exercise_atlantic_forest.laz

las = readLAS("data/exercice_atlantic_forest.laz")

# What does it contain? Is the ground segmented? What are the different point classes?
# Is it normalized? What is the point density? What is the point format? What is the difference
# with the file we used during the workshop

las
plot(las)
las_check(las)

# Normalize the file.

lasn = normalize_height(las, tin())
plot(lasn)

# There are some obvious ouliers below 0. Drop them.

lasn = filter_poi(lasn, Z >= 0)

# Now the point cloud is clean, what do you observe? How do you explain that? Do you think it is a
# good idea to normalize the dataset?

plot(lasn)

# When ploting the original dataset, points are colored by their absolute height. When plotting the
# normalized dataset the points are colored by their relative height but the topography is no longer
# visible. Find a way to display the non-normalized data but colored with the relative height.

Zcol = lasn$Z
lasn = unnormalize_height(lasn)
lasn = add_attribute(lasn, Zcol, "Zcol")

plot(lasn, color = "Zcol")

# Segment the trees by any mean you want. This segmentation should not run in more than 1-2 seconds.

chm = grid_canopy(las, 0.5, p2r(0.1))
plot(chm)

ttops = find_trees(chm, lmf(3.5))
plot(ttops, add = T)

las = segment_trees(las, dalponte2016(chm, ttops, max_cr = 20))

plot(las, color = "treeID", colorPalette = pastel.colors(500))

# Is this segmentation good enough? How to impove it? Test another algorithm. Is it a good idea to process
# non-normalized data? What to you propose to improve these results?
