###############################################
# STEP 2: HOST-ANNOTATED PHYLOGENY
###############################################

library(ape)
library(ggtree)
library(ggplot2)
library(openxlsx)
library(dplyr)
library(ggnewscale)
library(RColorBrewer)

source("../config/config.R")

cat("============================================\n")
cat("STEP 2: Host phylogeny visualisation\n")
cat("============================================\n")

###############################################
# FIX TREE FORMAT
###############################################

tree_text <- readLines(TREE_FILE)

tree_text_fixed <- gsub(
  "\\):(\\d*\\.?\\d*)\\[(\\d+)\\]",
  ")\\2:\\1",
  tree_text
)

tree_text_fixed <- gsub(
  "\\)\\[(\\d+)\\]",
  ")\\1",
  tree_text_fixed
)

temp_tree <- tempfile(fileext = ".tree")
writeLines(tree_text_fixed, temp_tree)

###############################################
# LOAD TREE
###############################################

tree <- read.tree(temp_tree)

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

metadata <- metadata %>%
  filter(label %in% tree_trimmed$tip.label)

###############################################
# HOST COLOURS
###############################################

metadata$Host <- ifelse(
  is.na(metadata$Host) | metadata$Host == "",
  "Other",
  metadata$Host
)

metadata$Host <- factor(metadata$Host)

hosts <- levels(metadata$Host)

host_colors <- setNames(
  colorRampPalette(
    brewer.pal(min(length(hosts), 12), "Set3")
  )(length(hosts)),
  hosts
)

###############################################
# SHAPES
###############################################

metadata$study_sample <- factor(
  metadata$study_sample,
  levels = c("no", "yes", "outgroup")
)

shape_values <- c(
  "no" = 16,
  "yes" = 15,
  "outgroup" = 17
)

###############################################
# MERGE
###############################################

p_data <- ggtree(tree_trimmed)$data

p_data$bootstrap <- NA
p_data$bootstrap[!p_data$isTip] <- as.numeric(tree_trimmed$node.label)

p_data <- p_data %>%
  left_join(metadata, by = c("label"))

###############################################
# PLOT
###############################################

p_final <- ggplot(p_data) +

  geom_tree(
    aes(x = x, y = y, color = bootstrap),
    size = 0.6,
    lineend = "round"
  ) +

  scale_color_gradient(
    low = "red",
    high = "green",
    na.value = "grey70",
    name = "Bootstrap"
  ) +

  ggnewscale::new_scale_color() +

  geom_point(
    data = subset(p_data, isTip == TRUE),
    aes(
      x = x,
      y = y,
      color = Host,
      shape = study_sample
    ),
    size = 3.5,
    stroke = 0.8
  ) +

  scale_color_manual(
    values = host_colors,
    drop = FALSE,
    name = "Host"
  ) +

  scale_shape_manual(
    values = shape_values,
    name = "Study Sample / Outgroup"
  ) +

  theme_tree2() +

  labs(
    title = "ORFV B2L Gene Phylogeny - Host"
  ) +

  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    legend.position = "right"
  )

###############################################
# SAVE
###############################################

ggsave(
  HOST_TREE_IMAGE,
  p_final,
  width = 15,
  height = 20,
  dpi = 1200
)

cat("Saved:\n")
cat(HOST_TREE_IMAGE, "\n")
