###############################################
# GLOBAL CONFIGURATION
###############################################

# Core directories
WORK_DIR <- "/path/to/phylogeny_visualisation"

# Inputs
TREE_FILE <- file.path(WORK_DIR, "b2l_rerooted.contree")
METADATA_FILE <- file.path(WORK_DIR, "All_orf_metadata.xlsx")
DISTANCE_FILE <- file.path(WORK_DIR, "b2l_Africa_subset.fasta.mldist")

# Outputs
OUTPUT_DIR <- file.path(WORK_DIR, "outputs")
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

MISSING_METADATA_FILE <- file.path(OUTPUT_DIR, "missing_sequences_in_metadata.txt")
TREE_METADATA_FILE <- file.path(OUTPUT_DIR, "b2l_tree_metadata.xlsx")

COUNTRY_TREE_IMAGE <- file.path(OUTPUT_DIR, "ORFV_B2L_tree_country.jpeg")
HOST_TREE_IMAGE <- file.path(OUTPUT_DIR, "ORFV_B2L_tree_host.jpeg")

PRELIM_HEATMAP_IMAGE <- file.path(OUTPUT_DIR, "B2L_HEATMAP_COLOR_UPGRADE.jpg")
FINAL_HEATMAP_IMAGE <- file.path(OUTPUT_DIR, "B2L_HEATMAP_FINAL_SPACED.jpg")

# Outgroups to exclude
REMOVE_TIPS <- c("NC_025963.1", "NC_005337.1")
