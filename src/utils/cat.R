## titles

cat.script_title <- function(title) {
  len <- nchar(title)
  spacer <- strrep("%", len)

  cat(paste("\n%%%", spacer, "%%%", sep = ""))
  cat(paste("\n%% ", title, " %%", sep = ""))
  cat(paste("\n%%%", spacer, "%%%\n\n", sep = ""))
}

cat.section_title <- function(title) {
  len <- nchar(title)
  spacer <- strrep("|", len)

  cat(paste("\n|||", spacer, "|||", sep = ""))
  cat(paste("\n|| ", title, " ||", sep = ""))
  cat(paste("\n|||", spacer, "|||\n\n", sep = ""))
}

cat.subsection_title <- function(title) {
  cat(paste("\n# ", title, "\n\n", sep = ""))
}

## json

cat.json <- function(json_obj, indent = 2) {
  printRecursive <- function(json_obj, indent_level) {
    if (is.list(json_obj)) {
      cat("\n")
      keys <- names(json_obj)
      for (key in keys) {
        cat(paste(rep(" ", indent_level * indent), collapse = ""))
        cat(sprintf("- %s : ", key))
        printRecursive(json_obj[[key]], indent_level + 1)
        cat("\n")
      }
      cat(paste(rep(" ", (indent_level - 1) * indent), collapse = ""))
    } else if (is.atomic(json_obj)) {
      cat(sprintf("%s", json_obj))
    }
  }

  printRecursive(json_obj, 1)
  cat("\n")
}
