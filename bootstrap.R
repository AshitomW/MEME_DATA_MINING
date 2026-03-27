create_project_sturcture <- function(root = ".") {
  dirs <- c(
    "data/raw",
    "data/processes",
    "data/images",
    "R",
    "models",
    "outputs/plots",
    "outputs/tables",
    "outputs/graphs",
    "tests",
    "logs"
  )

  for (d in dirs){
    full_path <- file.path(root, d)
    if (!dir.exists(full_path)) {
      dir.create(full_path, recursive = TRUE)
      cat("Created:", full_path, "\n")
    } else {
      cat("Exists:", full_path, "\n")
    }
  }

  gitignore_lines <- c(
    "data/raw/*",
    "data/images/*",
    "models/*.pt",
    "models/*.bin",
    "*.rds",
    "logs/*",
    "!data/raw/.gitkeep",
    "!data/images/.gitkeep"
  )

  writeLines(gitignore_lines, file.path(root, ".gitignore"))
  cat("Created .gitignore\n")


  gitkeep_dirs <- c("data/raw", "data/images", "data/processed", "models", "outputs/plots", "outputs/tables", "outputs/graphs", "logs")



  for (d in gitkeep_dirs){
    file.create(file.path(root, d, ".gitkeep"))
  }


  invisible(NULL)
}


create_project_sturcture()