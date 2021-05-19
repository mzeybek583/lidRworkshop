las = readLAS("data/MixedEucaNat_normalized.laz", select = "*",  filter = "-set_withheld_flag 0")

# 1. Assuming the biomass is predicted by this equation <B = 0.5 * mean Z + 0.9 * 90th percentile of Z>
#    applied on first returns only, map the biomass on this tiny file

B = grid_metrics(las, ~0.5*mean(Z) + 0.9*quantile(Z, probs = 0.9), 10, filter = ~ReturnNumber == 1L)
plot(B, col = height.colors(50))

# 2. Map the density of ground returns

GND = grid_metrics(las, ~length(Z)/25, res = 5, filter = ~Classification == LASGROUND)
plot(GND, col = heat.colors(50))

# 3. Map the pixel that are flat (road) using stdshapmetrics

m = grid_metrics(las, .stdshapemetrics, res = 3)
plot(m[["planarity"]], col = heat.colors(50))
flat = m[["planarity"]] > 0.85
plot(flat)
