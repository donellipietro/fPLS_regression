# % %%%%%%%%%%%%%% %
# % % Test: fPCA % %
# % %%%%%%%%%%%%%% %

rm(list = ls())
graphics.off()


## global variables ----

test_suite <- "example"
TEST_SUITE <- "fPCA"


## prerequisite ----
source(paste("tests/", test_suite, "/utils/generate_options.R", sep = ""))


## libraries ----

## json
suppressMessages(library(jsonlite))

## algebraic utils
suppressMessages(library(pracma))

## data visualization
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(viridis))
suppressMessages(library(stringr))
suppressMessages(library(RColorBrewer))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))

## sources ----
source("src/utils/directories.R")
source("src/utils/results_management.R")
source("src/utils/plots.R")


## paths ----
path_options <- paste("queue/", sep = "")
path_results <- paste("results/", test_suite, "/", sep = "")
path_images <- paste("images/", test_suite, "/", sep = "")
file_log <- "log.txt"


## options ----

## colors used in the plots
colors <- c(brewer.pal(3, "Greys")[3], brewer.pal(3, "Blues")[2:3])

## names and labels
names_models <- c("MV_PCA", "fPCA_off", "fPCA_kcv")
lables_models <- c("MV-PCA", "fPCA (no calibration)", "fPCA (kcv calibration)")


## load data ----

## check arguments passed by terminal
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  args[1] <- "test1"
}

## main test name
name_main_test <- args[1]
cat(paste("\nTest selected:", name_main_test, "\n"))
path_results <- paste(path_results, name_main_test, "/", sep = "")
path_images <- paste(path_images, name_main_test, "/", sep = "")
mkdir(path_images)

## generate options
generate_options(name_main_test, path_options)

## list of available tests
file_test_vect <- sort(list.files(path_options))

## room for solutions
names_columns <- c("Group", "n_nodes", "n_locs", "n_stat_units", names_models)
empty_df <- data.frame(matrix(NaN, nrow = 0, ncol = length(names_columns)))
colnames(empty_df) <- names_columns
times <- empty_df
rmses <- list()
irmses <- list()
angles <- list()


for (file_test in file_test_vect) {
  ## load specs
  file_json <- paste(path_options, file_test, sep = "")
  parsed_json <- fromJSON(file_json)
  name_test <- parsed_json$test$name_test
  n_nodes <- parsed_json$dimensions$n_nodes
  n_locs <- parsed_json$dimensions$n_locs
  n_stat_units <- parsed_json$dimensions$n_stat_units
  n_reps <- parsed_json$dimensions$n_reps

  cat(paste("\nTest ", name_test, ":\n", sep = ""))

  ## load batches
  for (i in 1:n_reps) {
    ## laod batch and log if not present
    sink(file_log, append = TRUE)
    tryCatch(
      {
        path_batch <- paste(path_results, name_test, "/", "batch_", i, "/", sep = "")
        load(paste(path_batch, "batch_", i, "_results_evaluation.RData", sep = ""))
      },
      error = function(e) {
        cat(paste("Error in test ", name_test, " - batch ", i, ": ", conditionMessage(e), "\n", sep = ""))
      }
    )
    sink()

    ## times
    times <- add_results(
      times,
      c(
        list(n_nodes = n_nodes, n_locs = n_locs, n_stat_units = n_stat_units),
        extract_new_results(results_evaluation, names_models, "execution_time")
      ),
      names_columns
    )

    ## rmse
    for (name in c("reconstruction_locs", "loadings_locs", "scores")) {
      rmses[[name]] <- add_results(
        rmses[[name]],
        c(
          list(n_nodes = n_nodes, n_locs = n_locs, n_stat_units = n_stat_units),
          extract_new_results(results_evaluation, names_models, c("rmse", name))
        ),
        names_columns
      )
    }

    ## irmse
    for (name in c("reconstruction", "loadings")) {
      irmses[[name]] <- add_results(
        irmses[[name]],
        c(
          list(n_nodes = n_nodes, n_locs = n_locs, n_stat_units = n_stat_units),
          extract_new_results(results_evaluation, names_models, c("irmse", name))
        ),
        names_columns
      )
    }

    ## angles
    for (name in c("orthogonality_m", "orthogonality_f")) {
      angles[[name]] <- add_results(
        angles[[name]],
        c(
          list(n_nodes = n_nodes, n_locs = n_locs, n_stat_units = n_stat_units),
          extract_new_results(results_evaluation, names_models, c("angles", name))
        ),
        names_columns
      )
    }

    cat(paste("- Batch", i, "loaded\n"))
  }

  ## remove option file
  file.remove(file_json)
}


## analysis ----

## names
name_aggregation_option_vect <- c("n_nodes", "n_stat_units", "n_locs")
name_group_vect <- c("K", "N", "S")

### time complexity ----

## open a pdf where to save the plots
pdf(paste(path_images, "time_complexity.pdf", sep = ""), width = 15, height = 15)

## data and titles
data_plot <- times
values_name <- "Time [seconds]"
title_vect <- paste(
  "Execution times w.r.t the",
  c(
    "number of nodes (K)",
    "number of statistical units (N)",
    "number of locations (S)"
  )
)

## options
options_grid <- list()
for (name_ao in name_aggregation_option_vect) {
  options_grid[[name_ao]] <- unique(data_plot[, name_ao])
}


for (i in 1:length(name_aggregation_option_vect)) {
  boxplot_list <- list()
  plot_list <- list()
  plot_loglog_list <- list()
  plot_loglog_normalized_list <- list()

  name_aggregation_option <- name_aggregation_option_vect[i]
  group_name <- name_group_vect[i]
  title <- title_vect[i]

  options_grid_selected <- options_grid
  options_grid_selected[[name_aggregation_option]] <- NULL
  names_options_selected <- names(options_grid_selected)
  labels_options_selected <- name_group_vect[-i]
  mg <- meshgrid(options_grid_selected[[1]], options_grid_selected[[2]])
  combinations_options <- data.frame(as.vector(mg[[1]]), as.vector(mg[[2]]))
  colnames(combinations_options) <- names_options_selected

  limits <- c(0, max(data_plot[, names_models]))
  range <- range(times[, names_models])

  labels_rows <- paste(labels_options_selected[1], "=", options_grid_selected[[1]])
  labels_cols <- paste(labels_options_selected[2], "=", options_grid_selected[[2]])

  for (j in 1:nrow(combinations_options)) {
    ## data preparation
    data_plot_trimmed <- data_plot[
      data_plot[, names_options_selected[1]] == combinations_options[j, 1] &
        data_plot[, names_options_selected[2]] == combinations_options[j, 2],
      c(name_aggregation_option, names_models)
    ]
    colnames(data_plot_trimmed) <- c("Group", names_models)
    indexes <- which(!is.nan(colSums(data_plot_trimmed[, names_models])))
    data_plot_aggregated <- aggregate(. ~ Group, data = data_plot_trimmed, FUN = median)

    ## plots
    boxplot_list[[j]] <- plot.grouped_boxplots(
      data_plot_trimmed[, c("Group", names(indexes))],
      values_name = NULL, # values_name,
      group_name = group_name,
      subgroup_name = "Approches",
      subgroup_labels = lables_models[indexes],
      subgroup_colors = colors[indexes],
      limits = limits,
      LEGEND = FALSE
    ) + standard_plot_settings()
    plot_list[[j]] <- plot.multiple_lines(
      data_plot_aggregated[, c("Group", names(indexes))],
      values_name = NULL, # values_name,
      x_name = group_name,
      x_breaks = TRUE,
      subgroup_name = "Approches",
      subgroup_labels = lables_models[indexes],
      subgroup_colors = colors[indexes],
      LEGEND = FALSE,
      limits = limits,
      NORMALIZED = FALSE,
      LOGX = TRUE
    ) + standard_plot_settings()
    plot_loglog_list[[j]] <- plot.multiple_lines(
      data_plot_aggregated[, c("Group", names(indexes))],
      values_name = NULL,
      x_name = group_name,
      x_breaks = TRUE,
      subgroup_name = "Approches",
      subgroup_labels = lables_models[indexes],
      subgroup_colors = colors[indexes],
      LEGEND = FALSE,
      limits = range,
      NORMALIZED = FALSE,
      LOGLOG = TRUE
    ) + standard_plot_settings()
    plot_loglog_normalized_list[[j]] <- plot.multiple_lines(
      data_plot_aggregated[, c("Group", names(indexes))],
      values_name = NULL,
      x_name = group_name,
      x_breaks = TRUE,
      subgroup_name = "Approches",
      subgroup_labels = lables_models[indexes],
      subgroup_colors = colors[indexes],
      LEGEND = FALSE,
      limits = c(1, limits[2]),
      NORMALIZED = TRUE,
      LOGLOG = TRUE
    ) + standard_plot_settings()
  }
  boxplot <- arrangeGrob(grobs = boxplot_list, ncol = length(labels_cols))
  boxplot <- labled_plots_grid(boxplot, title, labels_cols, labels_rows, 9, 7)
  grid.arrange(boxplot)
  plot <- arrangeGrob(grobs = plot_list, ncol = length(labels_cols))
  plot <- labled_plots_grid(plot, title, labels_cols, labels_rows, 9, 7)
  grid.arrange(plot)
  plot_loglog <- arrangeGrob(grobs = plot_loglog_list, ncol = length(labels_cols))
  plot_loglog <- labled_plots_grid(plot_loglog, title, labels_cols, labels_rows, 9, 7)
  grid.arrange(plot_loglog)
  plot_loglog_normalized <- arrangeGrob(grobs = plot_loglog_normalized_list, ncol = length(labels_cols))
  plot_loglog_normalized <- labled_plots_grid(plot_loglog_normalized, title, labels_cols, labels_rows, 9, 7)
  grid.arrange(plot_loglog_normalized)
}

dev.off()


### overall quantitative results ----


## open a pdf where to save the plots
pdf(paste(path_images, "overall_quantitative_results.pdf", sep = ""), width = 15, height = 15)

## reconstruction RMSE at locations
data_plot <- rmses[["reconstruction_locs"]]
title_vect <- paste(
  "Reconstruction RMSE at locations w.r.t the",
  c(
    "number of nodes (K)",
    "number of statistical units (N)",
    "number of locations (S)"
  )
)
limits <- NULL
source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))

## reconstruction IRMSE
data_plot <- irmses[["reconstruction"]]
title_vect <- paste(
  "Reconstruction IRMSE w.r.t the",
  c(
    "number of nodes (K)",
    "number of statistical units (N)",
    "number of locations (S)"
  )
)
limits <- NULL
source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))

## loadings
name_vect <- c("1", "2", "3")
for (k in 1:3) {
  data_plot <- rmses[["loadings_locs"]][rmses[["loadings_locs"]]$Group == k, ]
  title_vect <- paste(
    "Loadings at locations RMSE component", name_vect[k], "w.r.t the",
    c(
      "number of nodes (K)",
      "number of statistical units (N)",
      "number of locations (S)"
    )
  )
  limits <- NULL
  source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))
}
for (k in 1:3) {
  data_plot <- irmses[["loadings"]][irmses[["loadings"]]$Group == k, ]
  title_vect <- paste(
    "Loadings IRMSE component", name_vect[k], "w.r.t the",
    c(
      "number of nodes (K)",
      "number of statistical units (N)",
      "number of locations (S)"
    )
  )
  limits <- NULL
  source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))
}
for (k in 1:3) {
  data_plot <- rmses[["scores"]][rmses[["scores"]]$Group == k, ]
  title_vect <- paste(
    "Scores RMSE component", name_vect[k], "w.r.t the",
    c(
      "number of nodes (K)",
      "number of statistical units (N)",
      "number of locations (S)"
    )
  )
  limits <- NULL
  source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))
}


## orthogonality check
name_vect <- c("1-2", "1-3", "2-3")
for (k in 1:3) {
  data_plot <- angles[["orthogonality_m"]][angles[["orthogonality_m"]]$Group == k, ]
  title_vect <- paste(
    "Orthogonality check (l2) pair", name_vect[k], "w.r.t the",
    c(
      "number of nodes (K)",
      "number of statistical units (N)",
      "number of locations (S)"
    )
  )
  limits <- c(80, 100)
  source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))
}
for (k in 1:3) {
  data_plot <- angles[["orthogonality_f"]][angles[["orthogonality_f"]]$Group == k, ]
  title_vect <- paste(
    "Orthogonality check (L2) pair", name_vect[k], "w.r.t the",
    c(
      "number of nodes (K)",
      "number of statistical units (N)",
      "number of locations (S)"
    )
  )
  limits <- c(80, 100)
  source(paste("tests/", test_suite, "/templates/plot_overall.R", sep = ""))
}


dev.off()
