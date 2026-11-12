############################################################
## Figure 1: Study population characteristics
## Creates six individual figures and one composite figure
############################################################

#############################
## Libraries
#############################

library(readxl)
library(janitor)
library(dplyr)
library(ggplot2)
library(patchwork)

#############################
## User settings
#############################

PROJECT_DIR <- "/home/fadele/ARS_NACA_ORFV"

INPUT_FILE <- file.path(
  PROJECT_DIR,
  "Sample_metadata",
  "sample_details.xlsx"
)

FIG_DIR <- file.path(
  PROJECT_DIR,
  "analysis",
  "figures"
)

dir.create(FIG_DIR,
           recursive = TRUE,
           showWarnings = FALSE)

#############################
## Read data
#############################

data <- read_excel(INPUT_FILE) |>
  clean_names()

############################################################
## Common Theme
############################################################

my_theme <-

theme_bw(base_size = 13) +

theme(

  plot.title = element_text(
    face = "bold",
    hjust = 0.5,
    size = 14
  ),

  axis.title = element_text(face = "bold"),

  axis.text = element_text(color = "black"),

  legend.title = element_text(face = "bold"),

  panel.grid.minor = element_blank()

)

############################################################
## Figure A
## Samples by Country
############################################################

country_plot <-

data %>%
count(country) %>%

ggplot(aes(x = reorder(country, -n),
           y = n)) +

geom_col(width = 0.7) +

geom_text(

aes(label = paste0(
n,
"\n(",
round(n/sum(n)*100,1),
"%)"
)),

vjust = -0.4,
size = 4

) +

labs(

title = "Country",
x = "",
y = "Number of samples"

) +

my_theme

############################################################
## Figure B
## Sample Types
############################################################

sample_plot <-

data %>%
count(sample_type) %>%

ggplot(aes(x = reorder(sample_type, n),
           y = n)) +

geom_col() +

coord_flip() +

geom_text(

aes(label = paste0(
n,
" (",
round(n/sum(n)*100,1),
"%)"
)),

hjust = -0.15,
size = 3.5

) +

labs(

title = "Sample Type",
x = "",
y = "Number of samples"

) +

expand_limits(y = max(table(data$sample_type))*1.15) +

my_theme

############################################################
## Figure C
## Animal Type
############################################################

animal_plot <-

data %>%
count(animal_type) %>%

ggplot(aes(x = reorder(animal_type, n),
           y = n)) +

geom_col() +

coord_flip() +

geom_text(

aes(label = n),

hjust = -0.2,
size = 3.5

) +

labs(

title = "Animal Type",
x = "",
y = "Number of animals"

) +

expand_limits(y = max(table(data$animal_type))*1.15) +

my_theme

############################################################
## Figure D
## Sampling Setting
############################################################

setting_plot <-

data %>%
count(location_setting) %>%

ggplot(aes(x = reorder(location_setting, n),
           y = n)) +

geom_col() +

coord_flip() +

geom_text(

aes(label = paste0(
round(n/sum(n)*100,1),
"%"
)),

hjust = -0.2,
size = 3.5

) +

labs(

title = "Sampling Setting",
x = "",
y = "Number of samples"

) +

expand_limits(y = max(table(data$location_setting))*1.15) +

my_theme

############################################################
## Figure E
## Clinical Signs
############################################################

clinical_plot <-

data %>%
count(clinical_signs) %>%

ggplot(aes(x = reorder(clinical_signs, n),
           y = n)) +

geom_col() +

coord_flip() +

geom_text(

aes(label = n),

hjust = -0.2,
size = 3.5

) +

labs(

title = "Clinical Signs",
x = "",
y = "Number of animals"

) +

expand_limits(y = max(table(data$clinical_signs))*1.15) +

my_theme

############################################################
## Figure F
## Animal Type by Country
############################################################

country_animal_plot <-

ggplot(data,
       aes(country,
           fill = animal_type)) +

geom_bar() +

labs(

title = "Animal Type by Country",
x = "",
y = "Number of samples",
fill = "Animal Type"

) +

my_theme +

theme(

legend.position = "bottom"

)

############################################################
## Save Individual Figures
############################################################

ggsave(
file.path(FIG_DIR,"FigureA_Country.png"),
country_plot,
width = 6,
height = 7,
dpi = 1000
)

ggsave(
file.path(FIG_DIR,"FigureB_SampleType.png"),
sample_plot,
width = 9,
height = 6,
dpi = 1000
)

ggsave(
file.path(FIG_DIR,"FigureC_AnimalType.png"),
animal_plot,
width = 7,
height = 6,
dpi = 1000
)

ggsave(
file.path(FIG_DIR,"FigureD_Setting.png"),
setting_plot,
width = 10,
height = 5,
dpi = 1000
)

ggsave(
file.path(FIG_DIR,"FigureE_ClinicalSigns.png"),
clinical_plot,
width = 7,
height = 7,
dpi = 1000
)

ggsave(
file.path(FIG_DIR,"FigureF_CountryAnimal.png"),
country_animal_plot,
width = 7,
height = 6,
dpi = 1000
)

############################################################
## Combine into one publication-quality figure
############################################################

combined_figure <-

(country_plot +
sample_plot +
animal_plot) /

(setting_plot +
clinical_plot +
country_animal_plot) +

plot_layout(
guides = "collect"
) +

plot_annotation(

title = "Characteristics of the Study Population",

tag_levels = "A"

) &

theme(

plot.title = element_text(
face = "bold",
size = 18,
hjust = 0.5
),

plot.tag = element_text(
face = "bold",
size = 16
)

)

############################################################
## Save Combined Figure
############################################################

ggsave(

file.path(
FIG_DIR,
"Figure1_StudyPopulation_Composite.png"
),

combined_figure,

width = 30,
height = 20,
dpi = 1000

)

ggsave(

file.path(
FIG_DIR,
"Figure1_StudyPopulation_Composite.pdf"
),

combined_figure,

width = 25,
height = 15

)

############################################################
## Finished
############################################################

cat("\n=========================================\n")
cat("All figures have been created successfully.\n")
cat("Location:\n")
cat(FIG_DIR)
cat("\n=========================================\n")