library(lidR)
rm(list = ls(globalenv()))

# ======================================
#   LAS FUNCTIONS APPLIED TO A CATALOG
# ======================================


# A. Exercise
# ================================

# The function lasfilterdecimate can be applied to a LAScatalog
# - look at the available options
# - Decimate the catalog from 30 pt/m² to 5 pt/m²
# - Remove points below 0 and above 40 in the same time.

ctg = readLAScatalog("data/Farm_A/")
