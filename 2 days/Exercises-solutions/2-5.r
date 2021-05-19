# ======================================
#   LAS FUNCTIONS APPLIED TO A CATALOG
# ======================================


# A. Exercise
# ================================

# The function lasfilterdecimate can be applied to a LAScatalog
# - look at the available options
# - Decimate the catalog from 30 pt/m² to 5 pt/m²
# - Remove points below 0 and above 40 in the same time.

ctg = catalog("data/Farm_A/")

opt_output_files(ctg) <- "data/output/Farm_A_decimated/{ORIGINALFILENAME}"

new_ctg = lasfilterdecimate(ctg, homogenize(5))

ctg
new_ctg
