# R package requirements for this project

required_packages <- c(
  "readxl",
  "dplyr",
  "tidyr",
  "stringr",
  "readr",
  "janitor",
  "ggprism"
)

install_if_missing <- function(pkgs) {
  missing <- pkgs[!(pkgs %in% rownames(installed.packages()))]
  if (length(missing)) {
    install.packages(missing, dependencies = TRUE)
  }
}

install_if_missing(required_packages)
invisible(lapply(required_packages, library, character.only = TRUE))
