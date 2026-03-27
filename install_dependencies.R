install_project_deps <- function() {
  cran_packages <- c(
    "tibble", "dplyr", "tidyr", "purrr", "readr", "stringr",
    "httr", "httr2", "jsonlite", "rvest", "curl",
    "tidytext", "text2vec", "tokenizers", "SnowballC",
    "magick",
    "torch", "torchvision", "luz",
    "dbscan", "cluster", "factoextra",
    "igraph", "ggraph", "tidygraph",
    "ggplot2", "ggrepel", "patchwork", "scales", "viridis",
    "Rtsne", "uwot",
    "proxy",
    "yaml", "config",
    "digest", "progress", "glue", "fs", "cli",
    "reticulate",
    "testthat"
  )

  installed <- installed.packages()[, "Package"]
  to_install <- setdiff(cran_packages, installed)

  if (length(to_install) > 0) {
    cat("Installing", length(to_install), "packages...\n")
    install.packages(to_install, repos = "https://cloud.r-project.org")
  } else {
    cat("All CRAN packages are already installed")
  }


  if (!torch::torch_is_installed()) {
    torch::install_torch()
    cat("Installed torch backend.\n")
  }


  tryCatch({
    reticulate::py_install(
      packages = c("sentence-transformers", "torch", "Pillow"),
      envname = "meme-mining",
      pip = TRUE
    )
    cat("Python dependencies installed in `meme-mining` venv.\n")
  }, error = function(e) {
    cat("Python setup failed:", conditionMessage(e), "\n")
    cat("Install manually: pip install sentence-transformers torch Pillow\n")
  })

  invisible(NULL)
}

install_project_deps()