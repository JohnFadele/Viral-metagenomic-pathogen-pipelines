###############################################
# STEP 0: IDENTIFY TREE SEQUENCES MISSING METADATA
###############################################

library(ape)
library(openxlsx)
library(dplyr)

source("../config/config.R")

cat("============================================\n")
cat("STEP 0: Identify missing metadata\n")
cat("============================================\n")

###############################################
# LOAD TREE
###############################################

tree <- read.tree(TREE_FILE)

tree$tip.label <- sapply(strsplit(tree$tip.label, "\\|"), `[`, 1)
tree$tip.label <- gsub("^_R_", "", tree$tip.label)
tree$tip.label <- trimws(tree$tip.label)

tree_trimmed <- drop.tip(
  tree,
  REMOVE_TIPS[REMOVE_TIPS %in% tree$tip.label]
)

###############################################
# LOAD METADATA
###############################################

metadata <- read.xlsx(METADATA_FILE) %>%
  rename(label = sequence_id) %>%
  mutate(label = trimws(label))

###############################################
# IDENTIFY MISSING
###############################################

tree_labels <- tree_trimmed$tip.label
metadata_labels <- metadata$label

missing_in_metadata <- setdiff(tree_labels, metadata_labels)

###############################################
# REPORT
###############################################

cat("Sequences in tree:", length(tree_labels), "\n")
cat("Sequences in metadata:", length(metadata_labels), "\n")
cat("Missing sequences:", length(missing_in_metadata), "\n")

print(missing_in_metadata)

###############################################
# SAVE
###############################################

write.table(
  missing_in_metadata,
  MISSING_METADATA_FILE,
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE
)

cat("\nOutput saved to:\n")
cat(MISSING_METADATA_FILE, "\n")
