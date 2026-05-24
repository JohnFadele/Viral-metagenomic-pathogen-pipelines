###############################################
# STEP 1: COUNTRY-ANNOTATED PHYLOGENY
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
cat("STEP 1: Country phylogeny visualisation\n")
cat("============================================\n")

###############################################
# FIX TREE BOOTSTRAP FORMAT
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
# COUNTRY COLOURS
###############################################

metadata$Country <- ifelse(
  is.na(metadata$Country) | metadata$Country == "",
  "Other",
  metadata$Country
)

metadata$Country <- factor(metadata$Country)

focus_countries <- c(
  "Nigeria",
  "Botswana",
  "Ethiopia",
  "Zambia"
)

focus_colors <- c(
  "Nigeria" = "#1b9e77",
  "Botswana" = "#d95f02",
  "Ethiopia" = "#7570b3",
  "Zambia" = "#e7298a"
)

other_countries <- setdiff(
  levels(metadata$Country),
  focus_countries
)

other_colors <- setNames(
  colorRampPalette(
    brewer.pal(min(length(other_countries), 12), "Set3")
  )(length(other_countries)),
  other_countries
)

country_colors <- c(focus_colors, other_colors)

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
# MERGE TREE + METADATA
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
      color = Country,
      shape = study_sample
    ),
    size = 3,
    stroke = 0.8
  ) +

  scale_color_manual(
    values = country_colors,
    drop = FALSE,
    name = "Country"
  ) +

  scale_shape_manual(
    values = shape_values,
    name = "Study Sample / Outgroup"
  ) +

  theme_tree2() +

  labs(
    title = "ORFV B2L Gene Phylogeny - Country"
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
  COUNTRY_TREE_IMAGE,
  p_final,
  width = 15,
  height = 20,
  dpi = 1200
)

cat("Saved:\n")
cat(COUNTRY_TREE_IMAGE, "\n")
