## format

format_time <- function(t) {
  if (attr(t, "units") == "mins") {
    return(as.numeric(t) * 60)
  } else if (attr(t, "units") == "hours") {
    return(as.numeric(t) * 60 * 60)
  } else {
    return(as.numeric(t))
  }
}

## dataframes

add_results <- function(data, new, names_columns, groups_names = NULL) {
  n <- 0
  for(i in 1:length(new)) {
    n <- max(c(n, length(new[[i]])))
  }
  ## init
  if (is.null(groups_names)) {
    new_data <- data.frame(Group = paste(1:n))
  } else {
    new_data <- data.frame(Group = groups_names)
  }
  ## add columns
  for (subgroup in names_columns[-1]) {
    new_data <- cbind(new_data, new[[subgroup]])
  }
  colnames(new_data) <- names_columns
  ## append to given data
  data <- as.data.frame(rbind(data, new_data))
  colnames(data) <- names_columns
  return(data)
}

extract_new_results <- function(results_evaluation, names_models, name_result) {
  new_results <- list()
  for(name_model in names_models) {
    if(length(name_result) == 1){
      new_results[[name_model]] <- results_evaluation[[name_model]][[name_result]]
    } else if(length(name_result) == 2){
      new_results[[name_model]] <- results_evaluation[[name_model]][[name_result[1]]][[name_result[2]]]
    } else {
      stop()
    }
    if(length(new_results[[name_model]]) == 1 && "units" %in% names(attributes(new_results[[name_model]]))){
      new_results[[name_model]] <- format_time(new_results[[name_model]])
    }
    if(is.null(new_results[[name_model]])) {
      new_results[[name_model]] <- c(NaN)
    }
  }
  return(new_results)
}
