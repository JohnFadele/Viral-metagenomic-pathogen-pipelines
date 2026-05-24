###############################################
# STEP 4: PRELIMINARY HIERARCHICAL HEATMAP
###############################################

library(pheatmap)
library(readxl)
library(tidyverse)

source("../config/config.R")

cat("============================================\n")
cat("STEP 4: Preliminary genetic distance heatmap\n")
cat("============================================\n")

###############################################
# READ DISTANCE MATRIX
###############################################

raw <- read.table(
  DISTANCE_FILE,
  header = FALSE,
  skip = 1,
  fill = TRUE,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

seq_names <- raw[[1]]
dist_matrix <- raw[, -1]

rownames(dist_matrix) <- seq_names
colnames(dist_matrix) <- seq_names

dist_matrix <- as.matrix(dist_matrix)
storage.mode(dist_matrix) <- "numeric"

###############################################
# LOAD METADATA
###############################################

metadata <- read_excel(TREE_METADATA_FILE) %>%
  as.data.frame()

###############################################
# CLEAN + ALIGN
###############################################

metadata$sequence_id <- trimws(metadata$sequence_id)
rownames(dist_matrix) <- trimws(rownames(dist_matrix))

metadata <- metadata %>%
  filter(sequence_id %in% rownames(dist_matrix))

metadata <- metadata[
  match(rownames(dist_matrix), metadata$sequence_id),
]

###############################################
# COUNTRY LEVELS
###############################################

metadata$Country <- factor(
  metadata$Country,
  levels = c(
    "Nigeria",
    "Ethiopia",
    "Botswana",
    "Zambia"
  )
)

###############################################
# ANNOTATION
###############################################

annotation <- data.frame(
  Country = metadata$Country,
  Host = metadata$Host,
  study_sample = metadata$study_sample
)

rownames(annotation) <- metadata$sequence_id

###############################################
# COLOURS
###############################################

annotation_colors <- list(

  Country = c(
    "Nigeria" = "green",
    "Ethiopia" = "blue",
    "Botswana" = "purple",
    "Zambia" = "red"
  ),

  Host = c(
    "Ovis aries" = "#1b9e77",
    "Capra hircus" = "#d95f02",
    "Sus domesticus" = "#7570b3"
  ),

  study_sample = c(
    "yes" = "black",
    "no" = "grey80"
  )
)

###############################################
# SAVE HEATMAP
###############################################

jpeg(
  PRELIM_HEATMAP_IMAGE,
  width = 25,
  height = 20,
  units = "in",
  res = 1200
)

pheatmap(
  dist_matrix,

  annotation_row = annotation,
  annotation_col = annotation,

  annotation_colors = annotation_colors,

  clustering_method = "ward.D2",

  color = colorRampPalette(
    c("green", "yellow", "red")
  )(100),

  show_rownames = TRUE,
  show_colnames = TRUE,

  fontsize_row = 10,

  main = "B2L Genetic Distance Heatmap"
)

dev.off()

cat("Saved:\n")
cat(PRELIM_HEATMAP_IMAGE, "\n")
