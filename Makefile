# Define the Rscript command
RSCRIPT := Rscript

# Targets
.PHONY: install build install_fdaPDE2 install_femR clean distclean tests test_example

# Description for targets

# Default target
all: build

# Installation targets
install_fdaPDE2: 
	@echo "Installing fdaPDE2..."
	@$(RSCRIPT) src/installation/install_fdaPDE2.R
	
install_femR: 
	@echo "Installing femR..."
	@$(RSCRIPT) src/installation/install_femR.R

install: install_fdaPDE2 install_femR
	@echo "Installation completed."

# Test targets

test_example: build clean
	@echo "Running example tests..."
	@./run_tests.sh example test1

tests: test_example
	@echo "All tests completed."

# Test targets parallel

test_example_parallel: build clean
	@echo "Running example tests..."
	@./run_tests_parallel.sh example test1
	
tests_parallel: test_example_parallel
	@echo "All tests completed."

# Build target
build:
	@echo "Creating necessary directories..."
	@mkdir -p data
	@mkdir -p results
	@mkdir -p images
	@echo "Build completed."

# Clean targets
clean_options:
	@$(RM) -r queue/
	@$(RM) -r logs/


clean: clean_options
	@echo "Cleaning temporary files..."
	@$(RM) *.aux *.log *.pdf *.txt *.json
	@$(RM) .Rhistory
	@$(RM) .RData
	@echo "Cleanup completed."
	
	
distclean: clean
	@echo "Attention! This will remove additional generated files."
	@read -p "Are you sure you want to continue? [y/n]: " confirm && [ "$$confirm" = "y" ] || (echo "Cleanup aborted." && false)
	@echo "Removing additional generated files..."
	@$(RM) -r images/
	@$(RM) -r results/
	@echo "Additional cleanup completed."
