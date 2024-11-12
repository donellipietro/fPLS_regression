## install
if (!require("devtools", character.only = TRUE)) {
  install.packages("devtools")
}

## remove installed version
if (require("femR", character.only = TRUE)) {
  remove.packages("femR")
}

## reinstall the package
devtools::install_github("fdaPDE/femR", ref="stable") 
