generate_options <- function(name_main_test, path_queue) {
  ## create the directory if it does not exist
  mkdir(c(path_queue))
  
  ## name test suite
  test_suite <- "example"
  
  ## generate the options json files
  switch(name_main_test,
         test1 = {
           
           # Test 1:
           
           ## options grid
          n_nodes_vect <- c(20^2, 30^2)
          n_locs_vect <- c(600, 800) 
          n_stat_units_vect <- c(20, 30, 50)
           
           ## fixed options
           name_mesh <- "unit_square"
           name_mesh_short <- "us"
           
           locs_eq_nodes <- FALSE
           n_comp <- 3
           n_reps <- 3
           mean <- TRUE
           NSR <- 0.5 # NSR = Var[noise]/Var[X]
           
           ## assembly jsons           
           for (n_nodes in n_nodes_vect) {
             for (n_locs in n_locs_vect) {
               for (n_stat_units in n_stat_units_vect) {
                  name_test <- paste(
                    test_suite, name_main_test, name_mesh_short,
                    sprintf("%0*d", 4, n_nodes),
                    sprintf("%0*d", 4, n_locs),
                    sprintf("%0*d", 4, n_stat_units),
                    NSR, n_comp,
                    sep = "_"
                  )
                  json_list <- list(
                    test = list(
                      name_test = name_test
                    ),
                    mesh = list(
                      name_mesh = name_mesh
                    ),
                    dimensions = list(
                      n_nodes = n_nodes,
                      n_locs = n_locs,
                      n_stat_units = n_stat_units,
                      n_comp = n_comp,
                      n_reps = n_reps
                    ),
                    data = list(
                      mean = mean,
                      locs_eq_nodes = locs_eq_nodes
                    ),
                    noise = list(
                      NSR = NSR
                    )
                 )
                 write_json(json_list, path = paste(path_queue, name_test, ".json", sep = ""))
               }
             }
           }
         },
         {
           stop(paste("The test", name_main_test, "does not exist"))
         }
  )
}
