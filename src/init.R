# % %%%%%%%%%%%%%%%%%%%%%%% %
# % % Test initialization % %
# % %%%%%%%%%%%%%%%%%%%%%%% %

rm(list = ls())

## libraries ----
suppressMessages(library(jsonlite))

## sources ----
source("src/utils/directories.R")


## directories ----
path_options <- paste("queue/", sep = "")
mkdir(c(path_options))


## options ----

## check arguments passed by terminal
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  args[1] <- "example"
  args[2] <- "test1"
}

## main test name
name_test_main <- args[2]
cat(paste("\nTest selected:", name_test_main, "\n"))


## generation ----
source(paste("tests/", args[1], "/utils/generate_options.R", sep = ""))
generate_options(name_test_main, path_options)
