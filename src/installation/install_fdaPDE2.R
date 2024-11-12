## install
if (!require("devtools", character.only = TRUE)) {
  install.packages("devtools")
}

## remove installed version
if (require("fdaPDE2", character.only = TRUE)) {
  remove.packages("fdaPDE2")
}

## reinstall the package
install_github("donellipietro/fdaPDE-R-donelli")