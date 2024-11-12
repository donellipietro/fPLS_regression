# % %%%%%%%%%%%%%% %
# % % Test: fPCA % %
# % %%%%%%%%%%%%%% %

rm(list = ls())
graphics.off()

## global variables ----

test_suite <- "example"
TEST_SUITE <- "fPCA"


## libraries ----

## algebraic utils
suppressMessages(library(pracma))

## statistical utils
suppressMessages(library(MASS))

## visualization
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(viridis))
suppressMessages(library(stringr))
suppressMessages(library(RColorBrewer))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))

## sampling
suppressMessages(library(sf))
suppressMessages(library(sp))
suppressMessages(library(raster))


## sources ----
source("src/utils/domain_and_locations.R")
source("src/utils/meshes.R")
source("src/utils/plots.R")
source("src/utils/wrappers.R")
source("src/utils/errors.R")
source(paste("tests/", test_suite, "/utils/generate_2D_data.R", sep = ""))


## options ----

name_mesh <- "unit_square"
n_nodes <- 1600
n_locs <- 800
n_stat_units <- 200
locs_eq_nodes <- FALSE
n_comp <- 3
NSR_last_comp <- 0.2^2


## domain & locations ----

## load domain
generated_domain <- generate_domain(name_mesh, n_nodes)
domain <- generated_domain$domain
domain_boundary <- generated_domain$domain_boundary
loadings_true_generator <- generated_domain$loadings_true_generator
mesh <- generated_domain$mesh

## locations
locations <- generate_locations(generated_domain, locs_eq_nodes)


## data ----

## generate data
generated_data <- generate_2D_data(
  domain = domain,
  locs = locations,
  loadings_true_generator = loadings_true_generator,
  n_stat_units = n_stat_units,
  n_comp = n_comp,
  NSR_last_comp = NSR_last_comp,
  seed = 1,
  VERBOSE = TRUE
)

## view loadings
title <- "Loadings"
labels_cols <- as.list(paste("f", 1:n_comp, sep = ""))
loadings_true <- generated_data$loadings_true
loadings_true_locs <- generated_data$loadings_true_locs
limits <- range(loadings_true)
plot_list <- list()
for (h in 1:n_comp) {
  plot_list[[h]] <- plot.field_tile(
    domain$nodes, loadings_true[, h],
    LEGEND = FALSE, limits = limits,
    breaks = seq(limits[1], limits[2], length = 10),
    boundary = domain_boundary
  ) +
    standard_plot_settings_fields()
}
for (h in 1:n_comp) {
  plot_list[[n_comp + h]] <- plot.field_points(
    locations, loadings_true_locs[, h],
    LEGEND = FALSE, limits = limits,
    boundary = domain_boundary, size = 1.5
  ) +
    standard_plot_settings_fields()
}
plot <- arrangeGrob(grobs = plot_list, nrow = 2)
plot <- labled_plots_grid(
  plot,
  title = title,
  labels_cols = labels_cols,
  width = 5,
  height = 5
)
grid.arrange(plot)

## view scores
scores_true <- generated_data$scores_true
colnames(scores_true) <- c("s1", "s2", "s3")
boxplot(scores_true, main = "Scores distributions")
grid()
boxplot(scores_true, add = TRUE)
points(1:3, generated_data$sigma_s, type = "l", lty = 2, col = "red")

## noise distribution
noise <- generated_data$X - generated_data$X_true_locs
boxplot(noise, xaxt = "n", main = "Noise distribution")
abline(h = 0, col = "red", lty = 1)
abline(h = c(-generated_data$sigma_noise_x, generated_data$sigma_noise_x), col = "red", lty = 2)

## noise spatial correlation
plot_list <- list()
for (i in 1:9) {
  plot_list[[i]] <- plot.field_points(locations, noise[i, ], boundary = domain_boundary) + standard_plot_settings_fields() + ggtitle(paste("Noise sample", i))
}
plot <- arrangeGrob(grobs = plot_list, nrow = 3)
grid.arrange(textGrob("Noise samples", gp = gpar(fontsize = 14, fontface = "bold")), plot, heights = c(1, 4 * 3))

## data samples
n_samples <- 3
title <- "X samples"
labels_cols <- list("True", "True at locations", "Observed")
labels_rows <- as.list(paste("x", 1:n_samples, sep = ""))
plot_list <- list()
for (i in 1:n_samples) {
  limits <- range(generated_data$X[i, ])
  plot_list[[(i - 1) * n_samples + 1]] <- plot.field_tile(domain$nodes, generated_data$X_true[i, ], boundary = domain_boundary, limits = limits, ISOLINES = TRUE) + standard_plot_settings_fields()
  plot_list[[(i - 1) * n_samples + 2]] <- plot.field_points(locations, generated_data$X_true_locs[i, ], boundary = domain_boundary, limits = limits, size = 1.5) + standard_plot_settings_fields()
  plot_list[[(i - 1) * n_samples + 3]] <- plot.field_points(locations, generated_data$X[i, ], boundary = domain_boundary, limits = limits, size = 1.5) + standard_plot_settings_fields()
}
plot <- arrangeGrob(grobs = plot_list, nrow = n_samples)
plot <- labled_plots_grid(plot, title, labels_cols, labels_rows, 5, 5)
grid.arrange(plot)

## centered data samples
n_samples <- 3
title <- "X centered samples"
labels_cols <- list("True", "True at locations", "Observed")
labels_rows <- as.list(paste("x", 1:n_samples, sep = ""))
plot_list <- list()
for (i in 1:n_samples) {
  limits <- range(generated_data$X[i, ] - generated_data$X_mean_true_locs)
  plot_list[[(i - 1) * n_samples + 1]] <- plot.field_tile(domain$nodes, generated_data$X_c_true[i, ], boundary = domain_boundary, limits = limits, ISOLINES = TRUE) + standard_plot_settings_fields()
  plot_list[[(i - 1) * n_samples + 2]] <- plot.field_points(locations, generated_data$X_c_true_locs[i, ], boundary = domain_boundary, limits = limits, size = 1.5) + standard_plot_settings_fields()
  plot_list[[(i - 1) * n_samples + 3]] <- plot.field_points(locations, generated_data$X[i, ] - generated_data$X_mean_true_locs, boundary = domain_boundary, limits = limits, size = 1.5) + standard_plot_settings_fields()
}
plot <- arrangeGrob(grobs = plot_list, nrow = n_samples)
plot <- labled_plots_grid(plot, title, labels_cols, labels_rows, 5, 5)
grid.arrange(plot)

## assemble data
data <- fdaPDE2::functional_data(
  domain = domain,
  X = generated_data$X,
  locations = locations
)
