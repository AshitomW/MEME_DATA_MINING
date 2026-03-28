load_config <- function(path = "config.yaml") {
  if (!file.exists(path)) {
    stop(glue::glue("Configuration file not found: {path}"))
  }

  configuration <- yaml::read_yaml(path)
  required_keys <- c("project", "data", "text",
                     "embeddings", "clustering", "graph", "paths")


  missing <- setdiff(required_keys, names(configuration))
  if (length(missing) > 0) {
    stop(glue::glue("Missing config sections: 
                    {paste(missing, collapse = ', ')}"))
  }


  set.seed(configuration$project$seed)

  for (p in configuration$paths){
    if (!dir.exists(p)) {
      dir.create(p, recursive = TRUE)
    }
  }


  configuration
}

configuration_get <- function(configuration, ...) {
  keys <- list(...)
  result <- configuration
  for (key in keys) {
    result <- result[[key]]
    if (is.null(result)) {
      stop(glue::glue("Configuration key not found:
         {paste(keys, collapse = '$')}"))
    }
  }

  result
}
