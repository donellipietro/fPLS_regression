

## time
indexes <- which(!is.nan(colSums(times[, names_models])))
plot <- plot.grouped_boxplots(
  times[, c("Group", names(indexes))],
  values_name = "Time [seconds]",
  group_name = "",
  group_labels = "",
  subgroup_name = "Approaches",
  subgroup_labels = lables_models[indexes],
  subgroup_colors = colors[indexes]
) + standard_plot_settings() + ggtitle("Time")
print(plot)

## RMSE
names <- c("centering", "centering_locs", "reconstruction", "reconstruction_locs")
titles <- c("Centering", "Centering at locations", "Reconstruction", "Reconstruction at locations")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(rmses[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    rmses[[name]][, c("Group", names(indexes))],
    values_name = "RMSE",
    group_name = "",
    group_labels = "",
    subgroup_name = "Approaches",
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}
names <- c("loadings", "loadings_locs", "scores")
titles <- c("Loadings", "Loadings at locations", "Scores")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(rmses[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    rmses[[name]][, c("Group", names(indexes))],
    values_name = "RMSE",
    subgroup_name = "Approaches",
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}

## IRMSE
names <- c("centering", "reconstruction")
titles <- c("Centering", "Reconstruction")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(irmses[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    irmses[[name]][, c("Group", names(indexes))],
    values_name = "IRMSE",
    group_name = "",
    group_labels = "",
    subgroup_name = "Approaches",
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}
names <- c("loadings")
titles <- c("Loadings")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(irmses[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    irmses[[name]][, c("Group", names(indexes))],
    values_name = "IRMSE",
    subgroup_name = "Approaches",
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}

## angles
names <- c("subspaces_m", "components_m", "components_f")
titles <- c("Angle between subspaces",
            "Angle between components (l2)", "Angle between components (L2)")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(angles[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    angles[[name]][, c("Group", names(indexes))],
    values_name = "Angle",
    subgroup_name = "Approaches",
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}
names <- c("orthogonality_m", "orthogonality_f")
titles <- c("Orthogonality check (l2)", "Orthogonality check (L2)")
for (i in 1:length(names)) {
  name <- names[i]
  title <- titles[i]
  indexes <- which(!is.nan(colSums(angles[[name]][, names_models])))
  plot <- plot.grouped_boxplots(
    angles[[name]][, c("Group", names(indexes))],
    values_name = "Angle",
    subgroup_name = "Approaches",
    group_name = "Combinations",
    group_labels = c("1-2", "1-3", "2-3"),
    subgroup_labels = lables_models[indexes],
    subgroup_colors = colors[indexes]
  ) + standard_plot_settings() + ggtitle(title)
  print(plot)
}