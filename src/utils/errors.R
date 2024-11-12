# utils ----

## errors

norm_l2 <- function(x) {
  return(sqrt(as.numeric(t(x) %*% x)))
}

RMSE <- function(x) {
  x <- as.matrix(x)
  n_stat_unit <- ncol(x)
  n_locs <- nrow(x)
  return(sqrt(sum(x^2) / (n_stat_unit * n_locs)))
}

IRMSE <- function(x, model) {
  x <- as.matrix(x)
  n_stat_unit <- ncol(x)
  return(sqrt(sum(diag(t(x) %*% model$R0() %*% x)) / n_stat_unit))
}

## angles

angle_between_functions <- function(f1, f2, model) {
  norm_f1 <- sqrt(as.numeric(t(f1) %*% model$R0() %*% f1))
  norm_f2 <- sqrt(as.numeric(t(f2) %*% model$R0() %*% f2))
  f1_dot_f2 <- as.numeric(t(f1) %*% model$R0() %*% f2)
  return(acos(f1_dot_f2 / (norm_f1 * norm_f2)))
}
