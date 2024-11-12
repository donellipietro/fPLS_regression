mkdir <- function(paths) {
  for (path in paths) {
    if (!file.exists(path)) {
      dir.create(path)
    }
  }
}
