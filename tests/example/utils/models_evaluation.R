# performances evaluation ----


## utils

adjust_norms <- function(FF, SS) {
  n_comp <- ncol(SS)
  f_norms <- c()
  for (h in 1:n_comp) {
    f_norms[h] <- norm_l2(FF[, h])
    FF[, h] <- FF[, h] / f_norms[h]
    SS[, h] <- SS[, h] * f_norms[h]
  }
  return(list(loadings_locs = FF, scores = SS, norms = f_norms))
}


adjust_results <- function(F_hat_locs, S_hat, F_true_locs, Fs_hat_evaluated = NULL) {
  ## number of components
  n_comp <- ncol(S_hat)

  ## change signs to match the true ones
  for (h in 1:n_comp) {
    if (RMSE(F_hat_locs[, h] + F_true_locs[, h]) < RMSE(F_hat_locs[, h] - F_true_locs[, h])) {
      F_hat_locs[, h] <- -F_hat_locs[, h]
      S_hat[, h] <- -S_hat[, h]
      if (!is.null(Fs_hat_evaluated)) {
        for (i in 1:length(Fs_hat_evaluated)) {
          Fs_hat_evaluated[[i]][, h] <- -Fs_hat_evaluated[[i]][, h]
        }
      }
    }
  }

  ## normalize results at locations
  adjusted_results <- adjust_norms(F_hat_locs, S_hat)

  ## adjust data at nodes accordingly
  for (h in 1:n_comp) {
    if (!is.null(Fs_hat_evaluated)) {
      for (i in 1:length(Fs_hat_evaluated)) {
        Fs_hat_evaluated[[i]][, h] <- Fs_hat_evaluated[[i]][, h] / adjusted_results$norms[h]
      }
    }
  }

  return(list(
    loadings_locs = adjusted_results$loadings_locs,
    scores = adjusted_results$scores,
    loadings_evaluated_list = Fs_hat_evaluated
  ))
}

evaluate_results <- function(model, generated_data) {
  ## number of computed components
  n_comp <- generated_data$dimensions$n_comp

  ## room for results
  rmse <- list()
  irmse <- list()
  angles <- list()
  
  ## execution time
  execution_time <- model$results$execution_time

  ## RMSE at locations

  ## centering
  if(!is.null(model$results$X_mean_locs)){
    norm <- ifelse(RMSE(generated_data$X_mean_true_locs) == 0, 1, RMSE(generated_data$X_mean_true_locs))
    rmse$centering_locs <- RMSE(model$results$X_mean_locs - generated_data$X_mean_true_locs) / norm
  }

  ## loadings & scores

  if(!is.null(model$results$loadings)) {
    Fs_hat_evaluated <- list(loadings = model$results$loadings)
  }else {
    Fs_hat_evaluated <- NULL
  }
  adjusted_results <- adjust_results(
    model$results$loadings_locs,
    model$results$scores,
    generated_data$loadings_true_locs,
    Fs_hat_evaluated
  )
  for (h in 1:n_comp) {
    norm <- RMSE(generated_data$loadings_true_locs[, h])
    rmse$loadings_locs[h] <- RMSE(adjusted_results$loadings_locs[, h] - generated_data$loadings_true_locs[, h]) / norm
    norm <- RMSE(generated_data$scores_true[, h])
    rmse$scores[h] <- RMSE(adjusted_results$scores[, h] - generated_data$scores_true[, h]) / norm
  }

  ## data reconstruction
  norm <- RMSE(generated_data$X_true_locs)
  rmse$reconstruction_locs <- RMSE(model$results$X_hat_locs - generated_data$X_true_locs) / norm

  ## RMSE at nodes (if possible)
  if (model$model_traits$has_interpolator) {
    norm <- ifelse(RMSE(generated_data$X_mean_true) == 0, 1, RMSE(generated_data$X_mean_true))
    rmse$centering <- RMSE(model$results$X_mean - generated_data$X_mean_true) / norm
    for (h in 1:n_comp) {
      norm <- RMSE(generated_data$loadings_true[, h])
      rmse$loadings[h] <- RMSE(adjusted_results$loadings_evaluated_list$loadings[, h] - generated_data$loadings_true[, h]) / norm
    }
    norm <- RMSE(generated_data$X_true)
    rmse$reconstruction <- RMSE(model$results$X_hat - generated_data$X_true) / norm
  }

  ## IRMSE (if possible)
  if (model$model_traits$is_functional) {
    if(!is.null(model$results$X_mean)){
      norm <- IRMSE(generated_data$X_mean_true, model)
      norm <- ifelse(norm == 0, 1, norm)
      irmse$centering <- IRMSE(model$results$X_mean - generated_data$X_mean_true, model) / norm
    }
    for (h in 1:n_comp) {
      norm <- IRMSE(generated_data$loadings_true[, h], model)
      irmse$loadings[h] <- IRMSE(adjusted_results$loadings_evaluated_list$loadings[, h] - generated_data$loadings_true[, h], model) / norm
    }
    norm <- IRMSE(t(generated_data$X_true), model)
    irmse$reconstruction <- IRMSE(t(model$results$X_hat - generated_data$X_true), model) / norm
  }
  
  ## angles
  for (h in 1:n_comp) {
    angles$subspaces_m[h] <- 180 * subspace(adjusted_results$loadings_locs[, 1:h], generated_data$loadings_true_locs[, 1:h]) / pi
    angles$components_m[h] <- 180 * subspace(adjusted_results$loadings_locs[, h], generated_data$loadings_true_locs[, h]) / pi
    if (model$model_traits$is_functional) {
      angles$components_f[h] <- 180 * angle_between_functions(
        adjusted_results$loadings_evaluated_list$loadings[, h],
        generated_data$loadings_true[, h],
        model
      ) / pi
    }
    if (h < n_comp) {
      for (j in (h + 1):n_comp) {
        angles$orthogonality_m[h + j - 2] <- 180 * subspace(adjusted_results$loadings_locs[, h], adjusted_results$loadings_locs[, j]) / pi
        if (model$model_traits$is_functional) {
          angles$orthogonality_f[h + j - 2] <- 180 * angle_between_functions(
            adjusted_results$loadings_evaluated_list$loadings[, h],
            adjusted_results$loadings_evaluated_list$loadings[, j],
            model
          ) / pi
        }
      }
    }
  }

  return(list(
    execution_time = execution_time,
    rmse = rmse,
    irmse = irmse,
    angles = angles
  ))
}
