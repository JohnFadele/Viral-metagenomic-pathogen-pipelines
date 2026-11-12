
# ============================================================
# 02_ORFV_Assembly_DotMatrix_Normalized_v4.R
# Publication-quality dot matrix
# Colour represents relative performance (0-100)
# Uniform bubble sizes
# ============================================================

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(viridis)

# ============================================================
# USER SETTINGS
# ============================================================

PROJECT_DIR <- "/home/fadele/new_cattle_orfv"

INPUT_FILE <- file.path(PROJECT_DIR, "supplement_2.xlsx")
OUTPUT_DIR <- file.path(PROJECT_DIR, "analysis", "figures")

dir.create(
  OUTPUT_DIR,
  recursive = TRUE,
  showWarnings = FALSE
)

# ============================================================
# READ INPUT DATA
# ============================================================

df <- read_excel(INPUT_FILE)

required_cols <- c(
  "Sample_ID",
  "Animal_type",
  "Total_ORFV",
  "ORFV_proportion",
  "%ORF_Resolved",
  "%B2L_Resolved",
  "%F1L_Resolved"
)

miss <- setdiff(required_cols, names(df))

if (length(miss) > 0) {
  stop(paste("Missing:", paste(miss, collapse = ", ")))
}

# ============================================================
# NORMALISATION FUNCTION
# ============================================================

normalize <- function(x) {

  x <- as.numeric(x)

  if (max(x, na.rm = TRUE) == min(x, na.rm = TRUE)) {
    return(rep(100, length(x)))
  }

  (x - min(x, na.rm = TRUE)) /
    (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)) * 100
}

# ============================================================
# BUILD DATASET
# ============================================================

plot_df <- df %>%
  transmute(
    Animal_type,
    ORFV_Reads = log10(Total_ORFV + 1),
    ORFV_Proportion = ORFV_proportion,
    Genome_Recovery = `%ORF_Resolved`,
    B2L_Recovery = `%B2L_Resolved`,
    F1L_Recovery = `%F1L_Resolved`
  ) %>%
  mutate(
    Reads_norm  = normalize(ORFV_Reads),
    Prop_norm   = normalize(ORFV_Proportion),
    Genome_norm = normalize(Genome_Recovery),
    B2L_norm    = normalize(B2L_Recovery),
    F1L_norm    = normalize(F1L_Recovery),

    Composite_Score = rowMeans(
      cbind(
        Reads_norm,
        Prop_norm,
        Genome_norm,
        B2L_norm,
        F1L_norm
      ),
      na.rm = TRUE
    )
  ) %>%
  arrange(Animal_type, desc(Composite_Score)) %>%
  group_by(Animal_type) %>%
  mutate(
    Sample = paste0(Animal_type, "_", row_number())
  ) %>%
  ungroup()

plot_df$Sample <- factor(
  plot_df$Sample,
  levels = rev(plot_df$Sample)
)

# ============================================================
# CONVERT TO LONG FORMAT
# ============================================================

long_df <- plot_df %>%
  select(
    Sample,
    ORFV_Reads,
    ORFV_Proportion,
    Genome_Recovery,
    B2L_Recovery,
    F1L_Recovery
  ) %>%
  pivot_longer(
    -Sample,
    names_to = "Metric",
    values_to = "Value"
  ) %>%
  group_by(Metric) %>%
  mutate(
    Relative_Performance = normalize(Value)
  ) %>%
  ungroup()

# ============================================================
# FORCE BIOLOGICAL ORDER
# ============================================================

long_df$Metric <- factor(
  long_df$Metric,
  levels = c(
    "ORFV_Reads",
    "ORFV_Proportion",
    "Genome_Recovery",
    "B2L_Recovery",
    "F1L_Recovery"
  )
)

metric_labels <- c(
  ORFV_Reads = "ORFV Reads\n(log10)",
  ORFV_Proportion = "ORFV Proportion\n(%)",
  Genome_Recovery = "Genome Recovery\n(%)",
  B2L_Recovery = "B2L Recovery\n(%)",
  F1L_Recovery = "F1L Recovery\n(%)"
)

# ============================================================
# GENERATE FIGURE
# COLOUR ONLY REPRESENTS RELATIVE PERFORMANCE
# ALL BUBBLES HAVE UNIFORM SIZE
# ============================================================

p <- ggplot(
  long_df,
  aes(
    x = Metric,
    y = Sample,
    colour = Relative_Performance
  )
) +

  geom_point(
    size = 3.5,
    alpha = 0.95
  ) +

  scale_x_discrete(
    labels = metric_labels,
    drop = FALSE
  ) +

  scale_colour_viridis(
    option = "D",
    limits = c(0, 100),
    breaks = c(0, 25, 50, 75, 100),
    name = "Relative\nperformance"
  ) +

  labs(
    title = "Relative ORFV assembly performance across samples",
    x = NULL,
    y = NULL
  ) +

  theme_bw(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),

    axis.text.x = element_text(
      angle = 35,
      hjust = 1,
      face = "bold"
    ),

    axis.text.y = element_text(size = 9),

    panel.grid.major = element_line(
      colour = "grey92"
    ),

    panel.grid.minor = element_blank(),

    legend.position = "right",

    legend.title = element_text(
      face = "bold"
    )
  )

# ============================================================
# SAVE FIGURE
# ============================================================

ggsave(
  file.path(
    OUTPUT_DIR,
    "Figure1_ORFV_DotMatrix_Normalized_v4.png"
  ),
  p,
  width = 9,
  height = 8,
  dpi = 1000
)

ggsave(
  file.path(
    OUTPUT_DIR,
    "Figure1_ORFV_DotMatrix_Normalized_v4.pdf"
  ),
  p,
  width = 9,
  height = 8
)

# ============================================================
# COMPLETION MESSAGE
# ============================================================

cat("\n============================================================\n")
cat("Figure generation completed successfully.\n")
cat("Output directory:", OUTPUT_DIR, "\n")
cat("Colour: Relative performance (0-100)\n")
cat("Bubble size: Uniform (3.5)\n")
cat("Size legend: Removed\n")
cat("============================================================\n")
