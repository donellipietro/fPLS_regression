# Test Suite Creation Guide

This guide outlines the steps and conventions for creating a test suite to evaluate fdaPDE methods using this repository's test bench. Follow these instructions to structure your test suite and ensure compatibility with the provided utilities.

## Test Suite Architecture

A test suite consists of several components organized into a specific directory structure. Below is an overview (for the [example](./example/) test suite) of the recommended architecture:

```bash
.
├── check_data_generation.R
├── main.R
├── post_processing.R
├── templates
│   ├── fit_and_evaluate.R
│   ├── load_results.R
│   ├── plot_overall.R
│   ├── plot_qualitative_results.R
│   └── plot_quantitative_results.R
└── utils
 ├── generate_2D_data.R
 ├── generate_options.R
 └── models_evaluation.R
```

In general, the idea is that the test suite direcotories contain all the scripts that are specific for the test at hand.

**File Descriptions**

- [`check_data_generation.R`](./example/check_data_generation.R): Script for checking the correctness of data generation processes.
- [`main.R`](./main.R): Main script orchestrating the execution of tests and analyses.
- [`post_processing.R`](./example/post_processing.R): Script for performing post-processing tasks after test execution, such as result aggregation or visualization.

**Templates directory**

The templates directory contains template scripts used during the test suite execution. These scripts provides chunks of code that are used multiple time during the execution of the test suite. Below are the templates typically included:

- [`fit_and_evaluate.R`](./example/templates/fit_and_evaluate.R): Template for fitting models to data and evaluating their performance.
- [`load_results.R`](./example/templates/load_results.R): Template for loading and preprocessing test results.
- [`plot_overall.R`](./example/templates/plot_overall.R): Template for generating overall performance plots.
- [`plot_qualitative_results.R`](./example/templates/plot_qualitative_results.R): Template for generating qualitative performance plots.
- [`plot_quantitative_results.R`](./example/templates/plot_quantitative_results.R): Template for generating quantitative performance plots.

**Utils Directory**

The utils directory contains utility functions used within the test suite. These utilities facilitate data generation, parameter configuration, and model evaluation. Below are the typical utilities included:

- [`generate_2D_data.R`](./example/utils/generate_2D_data.R): Utility script for generating 2D data for testing purposes.
- [`generate_options.R`](./example/utils/generate_options.R): Utility script for generating options or configurations for testing.
- [`models_evaluation.R`](./example/utils/models_evaluation.R): Utility script containing functions for evaluating models and computing performance metrics.

## Facilitating Massive Tests Execution

This repository has been designed with the idea of facilitating the execution of massive tests with potentially numerous configurations to compare. The workflow involves the generation of configuration files for each test scenario using the [`generate_options.R`](./example/utils/generate_options.R) utility script. These configuration files are then stored in the `./queue/` directory, ready for execution.

### Generate Options

The [`generate_options.R`](./example/utils/generate_options.R) script generates configuration files for different test scenarios based on specified parameters. These configuration files define various aspects of the tests, such as domain, mesh, dimensions, data settings, and noise levels. By customizing the parameters and options in this script, users can define a wide range of test configurations to evaluate `fdaPDE` methods comprehensively.

### Implementation Example

Below is an example implementation of the [`generate_options.R`](./example/utils/generate_options.R) script:

```R
generate_options <- function(name_main_test, path_queue) {
  ## create the directory if it does not exist
  mkdir(c(path_queue))

  ## name test suite
  test_suite <- "example"

  ## generate the options json files
  switch(name_main_test,
         test1 = {
           # Test 1: test_name
           # - domain = unit_square_medium
           # - locations == nodes

           ## test name
           name_test_main <- "test1"

           ## options grid
           n_nodes_vect <- c(20^2, 30^2)
           n_locs_vect <- c(600, 800)
           n_stat_units_vect <- c(20, 30, 50)

           ## fixed options
           name_mesh <- "unit_square"
           name_mesh_short <- "us"

           locs_eq_nodes <- FALSE
           n_comp <- 3
           n_reps <- 11 # odd number to avoid errors in qualitative results plots
           NSR <- 1^2 # NSR = Var[noise]/Var[X]

           ## assembly jsons
           for (n_nodes in n_nodes_vect) {
             for (n_locs in n_locs_vect) {
               for (n_stat_units in n_stat_units_vect) {
                 name_test <- paste(
                   test_suite, name_test_main, name_mesh_short,
                   sprintf("%0*d", floor(log10(max(n_nodes_vect))) + 1, n_nodes),
                   sprintf("%0*d", floor(log10(max(n_locs_vect))) + 1, n_locs),
                   sprintf("%0*d", floor(log10(max(n_stat_units_vect))) + 1, n_stat_units),
                   NSR, n_comp,
                   sep = "_"
                 )
                 json_list <- list(
                   ## ...
                 )
                 write_json(json_list, path = paste(path_queue, name_test, ".json", sep = ""))
               }
             }
           }
         },
         ## ...
  )
}
```

As clear from the script, the complexity of dealing with multiple configurations is handled by this script that generates a list of configuration files. In this way, the main script it's much cleaner because it only needs to import the configuration file and execute a single test.

### Execution Workflow

The [`./run_tests.sh`](../run_tests.sh) script first calls the `generate_options` script for the desired test by means of [init.R](../src/init.R), then retrieves the test configurations from the `./queue/` directory and calls the appropriate `main.R` script for each test scenario. This modular approach enables easy parallelization of tests execution, allowing for efficient utilization of computational resources and faster evaluation of methods.

By following this approach, each call of a `main.R` script produces results and figures relative to that specific call. When each configuration has been analysed, the `post_processing.R` imports all the saved results and produces overall results figures.
