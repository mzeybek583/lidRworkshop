library(lidR)
rm(list = ls(globalenv()))

# ======================================
#   SELECTION OF POINTS OF INTEREST
# ======================================

las = readLAS("data/MixedEucaNat_normalized.laz", select = "*")

las

plot(las)


# A. filter_poi* function allows for filtering points of interest algoritmically
# ============================================================================

?filter_poi
?filters

# Filter first return

firstreturns = filter_poi(las, ReturnNumber == 1)
firstreturns
plot(firstreturns)

# Filter first return above 5 m.

firstreturnover5 = filter_poi(las, Z >= 5, ReturnNumber == 1)
plot(firstreturnover5)

# filter surface points

surfacepoints = filter_surfacepoints(las, 0.5)
plot(surfacepoints)

# B. Think about memory usage !!
# ==============================

# las + firstreturn + firstreturnover5 ~= 3 copies of the original point cloud. When manipulating
# *big* data, one must be careful. Lidar point clouds may be huge. Here it does not matter.

pryr::object_size(las)
pryr::object_size(firstreturns)
pryr::object_size(firstreturnover5)

pryr::object_size(las, firstreturns, firstreturnover5)

# One can do the following trick to erase original object

las = filter_poi(las, Z > 5, ReturnNumber == 1)

# But in pratice this is not very efficient because of the way R deals with memory
# (To study this advanced topic search for 'R garbage collector' in a search engine)


# The filter* functions are really useful to the user to filter the data. But we must be careful
# with the memory usage if we manipulate *big* data in memory. This is a specific limitation of R itself.
# To get subset of the data we ACTUALLY NEED to make a copy of the dataset.

# C. Be clever, use the filter argument from readLAS (streaing filter)
# ==================================================

# A more efficient filter (both in term of speed and memory) is filtering the points of interest
# while reading the file. This way, no memory is uselessly allocated at the R level. Everything is
# done at the C++ level.

las = readLAS("data/MixedEucaNat_normalized.laz", filter = "-drop_z_below 5 -keep_first", select = "xyz")
las

plot(las)

# But some filter have no streaming equivalent, for example 'filter_surfacepoints()'


