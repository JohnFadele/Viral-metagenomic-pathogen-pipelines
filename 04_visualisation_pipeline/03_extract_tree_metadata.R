###############################################
# STEP 3: EXTRACT TREE-SPECIFIC METADATA
###############################################

library(ape)
library(openxlsx)
library(dplyr)
library(stringr)

source("../config/config.R")

cat("============================================\n")
cat("STEP 3: Extract tree metadata\n")
cat("============================================\n")

###############################################
# LOAD TREE
###############################################

tree <- read.tree(TREE_FILE)

tree$tip.label <- sapply(strsplit(tree$tip.label, "\\|"), `[`, 1)
tree$tip.label <- gsub("^_R_", "", tree$tip.label)
tree$tip.label <- str_trim(tree$tip.label)

tree_sequences <- data.frame(sequence_id = tree$tip.label)

###############################################
# LOAD METADATA
###############################################

metadata <- read.xlsx(METADATA_FILE)

metadata <- metadata %>%
  mutate(
    sequence_id = str_trim(as.character(sequence_id)),
    Host = str_trim(as.character(Host)),
    Country = str_trim(as.character(Country)),
    Year = as.character(Year),
    study_sample = str_trim(as.character(study_sample))
  )

###############################################
# FILTER
###############################################

tree_metadata <- metadata %>%
  filter(sequence_id %in% tree_sequences$sequence_id)

missing_sequences <- setdiff(
  tree_sequences$sequence_id,
  tree_metadata$sequence_id
)

###############################################
# ADD MISSING
###############################################

if (length(missing_sequences) > 0) {

  missing_df <- data.frame(
    sequence_id = missing_sequences,
    Host = "Unknown",
    Country = "Unknown",
    Year = NA,
    study_sample = "no",
    stringsAsFactors = FALSE
  )

  tree_metadata <- bind_rows(tree_metadata, missing_df)
}

###############################################
# REORDER
###############################################

tree_metadata <- tree_metadata %>%
  mutate(sequence_id = factor(
    sequence_id,
    levels = tree_sequences$sequence_id
  )) %>%
  arrange(sequence_id)

###############################################
# SAVE
###############################################

write.xlsx(
  tree_metadata,
  TREE_METADATA_FILE,
  overwrite = TRUE
)

###############################################
# SUMMARY
###############################################

cat("Total sequences in tree:", nrow(tree_sequences), "\n")
cat("Matched metadata:",
    nrow(tree_metadata) - length(missing_sequences), "\n")
cat("Missing metadata added:",
    length(missing_sequences), "\n")

cat("Output saved to:\n")
cat(TREE_METADATA_FILE, "\n")
