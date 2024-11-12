# fdaPDE Methods Test Bench

## Overview

This repository serves as a test bench specifically designed for evaluating methods related to [fdaPDE](https://fdapde.github.io) (Physics-Informed Spatial and Functional Data Analysis). It provides a collection of utilities and scripts to facilitate the testing process, including model evaluation metrics computation, plot generation, and automation of tests with various parameter configurations.

## Features

- **Model Evaluation Metrics:** Utilities are available for computing various model evaluation metrics (`RMSE`, `IRMSE`, `...`), allowing for comprehensive assessment of fdaPDE methods' performance.
- **Plot Generation:** The repository includes tools for generating plots to visualize the results of the tested methods, aiding in the interpretation and analysis of the experimental outcomes.
- **Test Automation:** Scripts are provided for automating the execution of tests with different parameter configurations. The `run_tests.sh` script facilitates the setup and execution of test suites, streamlining the testing process.

## Usage

### Running Tests

To run tests using the provided utilities, follow these steps::

1. Create a new directory in test containing all the tests scripts (an example test has been created as a reference).
2. Execute the `run_tests.sh` script, passing the test suite name and test name as arguments. For example:

   ```bash
   ./run_tests.sh example test1
   ```

3. The script initializes the test environment, then iterates over the options files in the specified directory, executing the main test script (main.R) for each file found.
4. After completing the tests, the script performs post-processing tasks, including runtime complexity analysis.

### Makefile

The `Makefile` provided in this repository includes several targets to automate common tasks related to installation, testing, building, and cleaning up the project environment. Below is a brief description of each target:

- `install_fdaPDE2`: Installs the `fdaPDE2` package by executing the `install_fdaPDE2.R` script located in the `src/installation/` directory.
- `install_femR`: Installs the `femR` package by executing the `install_femR.R` script located in the `src/installation/ directory`.
- `install`: Combines the `install_fdaPDE2` and `install_femR` targets to install both the `fdaPDE2` and `femR` packages.
- `test_example`: Runs example tests by executing the `run_tests.sh` script with the arguments example and test1.
- `tests`: Combines the `build`, `clean`, and `test_example` targets to perform a complete test run, ensuring that tests are executed on a clean environment after building.
- `build`: Creates necessary directories for data, results, and images. This target ensures the directory structure required for the project is in place.
- `clean_options`: Cleans temporary files by removing the `queue/` directory.
- `clean`: Combines the `clean_options` target with additional cleanup tasks, such as removing auxiliary files, R history, and data files.
- `distclean`: Combines the `clean` target with further cleanup actions, including the removal of additional generated files like images and results. It prompts for confirmation before executing to avoid accidental deletion.

These targets can be executed using the make command followed by the target name, for example, to run all tests:

```bash
make tests
```

Refer to the [`Makefile`](./Makefile) for implementation details and additional customization options.

## Repository structure

```bash
.
├── LICENSE
├── Makefile
├── README.md
├── run_tests.sh
├── data
│   └── mesh
│       ├── ...
├── src
│   ├── installation
│   │   ├── install_fdaPDE2.R
│   │   └── install_femR.R
│   └── utils
│       ├── cat.R
│       ├── directories.R
│       ├── meshes.R
│       ├── domain_and_locations.R
│       ├── errors.R
│       ├── results_management.R
│       ├── plots.R
│       └── wrappers.R
├── analysis
└── tests
```

**Files**:

- **LICENSE**: GPL v3 License file specifying the terms and conditions for using the repository.
- **Makefile**: Makefile for automating build tasks or running commands.
- **README.md**: This documentation file providing an overview of the repository and its usage instructions.
- **run_tests.sh**: Script for automating the execution of tests with different parameter configurations.

**Directories**:

- **data**: Directory storing general data files, including mesh data used in tests.
- **src**: Source code directory containing installation scripts and utility functions.
- **tests**: Directory for storing test scripts and related resources.
- **analysis**: Directory containing analysis-related scripts or resources.

## Authorship

This test bench repository is maintained by Pietro Donelli.

## License

This repository is licensed under the GPL v3 License. See the [LICENSE](./LICENSE) file for details.
