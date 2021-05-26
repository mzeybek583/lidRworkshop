# 1. What are the withhelp point? Where are they?

  # According to ASPRS LAS specification http://www.asprs.org/wp-content/uploads/2019/07/LAS_1_4_r15.pdf
  # page 18 "a point that should not be included in processing (synonymous with Deleted)"

  # They are on the edges. It looks like they correspond to a buffer. LAStools makes use of the withheld
  # bit to flag some points. Without more information on former processing step it is hard to say.

# 2. Read the file dropping the withheld points

las <- readLAS("data/MixedEucaNat_normalized.laz", filter = "-drop_withheld")


# 3. The withheld points seem legit actually. Try to load the file including the withheld point
#    but get rid of the warning (without using suppressWarnings()). Hint: use transformation

las <- readLAS("data/MixedEucaNat_normalized.laz", filter = "-set_withheld_flag 0")

# 4. Load only the ground points and plot the point cloud coloured by the return number of the points.
#    Do it loading the strict minimal amount of memory (4.7 Mb)

las <- readLAS("data/MixedEucaNat_normalized.laz", filter = "-keep_class 2 -set_withheld_flag 0", select = "r")
plot(las, color = "ReturnNumber", legend = T)
format(object.size(las), "Mb")
