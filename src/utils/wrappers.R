SpatialPCA_wrapped <- function(data, n_comp = 3) {
  ## data
  counts <- data$X
  locations <- data$locations
  S <- ncol(counts)
  N <- nrow(counts)

  ## "fake" model initialization
  colnames(counts) <- paste("P", 1:S, sep = "")
  rownames(counts) <- paste("F", 1:N, sep = "")
  rownames(locations) <- paste("P", 1:S, sep = "")

  suppressWarnings(
    model_SpatialPCA <- CreateSpatialPCAObject(
      counts = counts,
      location = locations,
      project = "SpatialPCA",
      gene.type = "none",
      sparkversion = "sparkx",
      numCores_spark = 5,
      gene.number = NULL,
      customGenelist = NULL,
      min.loctions = 20,
      min.features = 20
    )
  )

  start.time <- Sys.time()

  ## model initialization
  model_SpatialPCA@params <- list()
  model_SpatialPCA@location <- locations
  model_SpatialPCA@normalized_expr <- counts

  ## solve
  sink("log.txt")
  model_SpatialPCA <- SpatialPCA_buildKernel(model_SpatialPCA,
    kerneltype = "gaussian",
    bandwidthtype = "SJ",
    bandwidth.set.by.user = NULL
  )
  model_SpatialPCA <- SpatialPCA_EstimateLoading(model_SpatialPCA,
    fast = FALSE,
    SpatialPCnum = n_comp
  )
  model_SpatialPCA <- SpatialPCA_SpatialPCs(model_SpatialPCA, fast = FALSE)
  sink()

  ## results
  loadings <- t(SpatialPCA_highresolution(model_SpatialPCA, platform = "Other", newlocation = data$domain$nodes)@highPCs)
  loadings_locs <- t(model_SpatialPCA@SpatialPCs)
  scores <- model_SpatialPCA@W

  end.time <- Sys.time()

  return(list(
    execution_time = end.time - start.time,
    model = model_SpatialPCA,
    evaluate_loadings = function(model, grid) {
      return(t(SpatialPCA_highresolution(model, platform = "Other", newlocation = grid)@highPCs))
    },
    results = list(
      loadings = loadings,
      loadings_locs = loadings_locs,
      scores = scores,
      X_hat = scores %*% t(loadings),
      X_hat_locs = scores %*% t(loadings_locs)
    )
  ))
}


MV_PCA_wrapped <- function(data, center = TRUE, n_comp = 3) {
  ## data
  X <- data$X
  
  ## centering
  X_mean_locs <- rep(0, ncol(X))
  if(center) {
    X_mean_locs <- colMeans(X)
    X <- scale(X, center = TRUE, scale = FALSE)
  }

  # MV-PCA
  model_MV_PCA <- prcomp(X, center = FALSE, rank. = n_comp)

  ## results
  loadings_locs <- model_MV_PCA$rotation
  scores <- model_MV_PCA$x
  X_hat_locs <- scores %*% t(loadings_locs) + rep(1, nrow(scores)) %*% t(X_mean_locs)
  
  return(list(
    model = model_MV_PCA,
    results = list(
      loadings = NULL,
      loadings_locs = loadings_locs,
      scores = scores,
      X_mean = NULL,
      X_mean_locs = X_mean_locs,
      X_hat = NULL,
      X_hat_locs = X_hat_locs
    )
  ))
}


ColMean_wrapped <- function(data) {
  ## data
  X <- data$X
  
  ## centering
  X_mean_locs <- colMeans(X)
  
  return(list(
    model = NULL,
    results = list(
      X_mean = NULL,
      X_mean_locs = X_mean_locs
    )
  ))
}

