###############################################
# STEP 5: CLUSTERED HEATMAP
###############################################

library(pheatmap)
library(readxl)
library(tidyverse)

source("../config/config.R")

cat("============================================\n")
cat("STEP 5: Cluster-labelled heatmap\n")
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
# COUNTRY
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
# CLUSTERING
###############################################

hc <- hclust(
  dist(dist_matrix),
  method = "ward.D2"
)

row_clusters <- cutree(hc, k = 3)

cluster_labels <- LETTERS[row_clusters]

###############################################
# REORDER
###############################################

cluster_order <- order(row_clusters)

dist_matrix <- dist_matrix[
  cluster_order,
  cluster_order
]

metadata <- metadata[cluster_order, ]
cluster_labels <- cluster_labels[cluster_order]

###############################################
# GAP POSITIONS
###############################################

cluster_sorted <- row_clusters[cluster_order]
gaps <- which(diff(cluster_sorted) != 0)

###############################################
# ANNOTATION
###############################################

annotation <- data.frame(
  Country = metadata$Country,
  Host = metadata$Host,
  study_sample = metadata$study_sample,
  Cluster = factor(
    cluster_labels,
    levels = c("A", "B", "C")
  )
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
  ),

  Cluster = c(
    "A" = "#e41a1c",
    "B" = "#377eb8",
    "C" = "#4daf4a"
  )
)

###############################################
# SAVE
###############################################

jpeg(
  FINAL_HEATMAP_IMAGE,
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

  cutree_rows = 3,

  gaps_row = gaps,
  gaps_col = gaps,

  color = colorRampPalette(
    c("green", "yellow", "red")
  )(100),

  show_rownames = TRUE,
  show_colnames = TRUE,

  fontsize_row = 10,

  main = "B2L Genetic Distance Heatmap with Cluster Separation"
)

dev.off()

cat("Saved:\n")
cat(FINAL_HEATMAP_IMAGE, "\n")
