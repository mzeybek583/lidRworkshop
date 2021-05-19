# Using:
las = readLAS("data/example_corrupted.laz", select = "xyz")
col1 = height.colors(50)
col2 = pastel.colors(900)

# - Run las_check() and fix the errors

las_check(las)

las = filter_duplicates(las)

las_check(las)

# - Find the trees and count the trees

ttops = find_trees(las, lmf(3, 5))
x = plot(las)
add_treetops3d(x, ttops)

# - Compute and map the density of trees with a 10 m resolution [1]

r = raster::raster(ttops)
res(r) = 10
r = raster::rasterize(ttops, r, "treeID", fun = 'count')
plot(r, col = viridis::viridis(20))

# - Segment the trees

chm = grid_canopy(las, 0.5, p2r(0.15))
plot(chm, col = col1)
ttops = find_trees(chm, lmf(2.5))
las = segment_trees(las, dalponte2016(chm, ttops))

plot(las, color = "treeID", colorPalette = col2)

# - Assuming that a value of interest of a tree can be estimated using the crown area and the mean Z
#   of the points with the formula <2.5 * area + 3 * mean Z>. Estimate the value of interet of each tree

value_of_interest = function(x,y,z)
{
  m = stdtreemetrics(x,y,z)
  avgz = mean(z)
  v = 2.5*m$convhull_area + 3 * avgz
  return(list(V = v))
}

V = tree_metrics(las, func = ~value_of_interest(X,Y,Z))
spplot(V, "V")

# Map the total biomass at a resolution of 10 m. The output is a mixed of ABA and ITS

Vtot = rasterize(V, r, "V", fun = "sum")
plot(Vtot, col = viridis::viridis(20))
