library(digest)
library(fs)


safe_save <- function(obj, path, log = NULL) {
  saveRDS(obj, path)
  checksum <- digest::digest(obj, algo = "md5")


  meta <- list(
    path = path,
    checksum = checksum,
    saved_at = Sys.time(),
    size_mb = round(file.size(path) / 1024^2, 2),
    class = class(obj),
    dimensions = if (is.data.frame(obj)) dim(obj) else length(obj)
  )
  meta_path <- paste0(path, ".meta.rds")
  saveRDS(meta, meta_path)

  if (!is.null(log)) {
    log$info("Saved {path} ({meta$size_mb} MB, checksum: {checksum})")
  }
  invisible(meta)
}


safe_load <- function(path, log = NULL) {
  if (!file.exists(path)) {
    stop(glue::glue("File not found: {path}"))
  }

  obj <- readRDS(path)
  meta_path <- paste0(path, ".meta.rds")
  if (file.exists(meta_path)) {
    meta <- readRDS(meta_path)
    current_checksum <- digest::digest(obj, algo = "md5")
    if (current_checksum != meta$checksum) {
      warning(glue::glue("Checksum mismatched 
      for {path}! Data is possibly corrupted."))
    }
  }

  if (!is.null(log)) {
    log$info("Loaded {path}")
  }
  obj
}


step_cached <- function(output_path, input_paths = NULL) {
  if (!file.exists(output_path)) return(FALSE)
  if (is.null(input_paths)) return(TRUE)

  output_time <- file.mtime(output_path)
  input_times <- sapply(input_paths, file.mtime)


  all(output_time > input_times)
}



retry <- function(expr, max_attempts = 3, delay = 2, log = NULL) {
  for (attempt in seq_len(max_attempts)) {
    result <- tryCatch(
      expr,
      error = function(e) {
        if (!is.null(log)) {
          log$warn("Attempt {attempt}/{max_attempts}
           failed: {conditionMessage(e)}")
        }
        if (attempt < max_attempts) {
          Sys.sleep(delay * attempt)
        }
        NULL
      }
    )
    if (!is.null(result)) return(result)
  }
  stop("All retry attempts exhausted")
}


timed <- function(label, expr, log = NULL) {
  start <- proc.time()
  result <- force(expr)
  elapsed <- (proc.time() - start)["elapsed"]

  msg <- glue::glue("{label}: {round(elapsed, 2)}s")
  if (!is.null(log)) {
    log$info(msg)
  } else {
    cat(msg, "\n")
  }

  result
}



batch_process <- function(items, fn, batch_size = 50, log = NULL) {
  n <- length(items)
  n_batches <- ceiling(n / batch_size)
  results <- vector("list", n)

  if (!is.null(log)) {
    log$info("Processing {n} items in {n_batches} batches of {batch_size}")
  }

  pb <- progress::progress_bar$new(
    format = "  [:bar] :current/:total (:percent) eta: :eta",
    total = n_batches,
    clear = FALSE
  )


  for (i in seq_len(n_batches)) {
    start_index <- (i - 1) * batch_size + 1
    end_index <- min(i * batch_size, n)
    batch <- items[start_index:end_index]

    batch_results <- lapply(batch, function(item) {
      tryCatch(fn(item), error = function(e) {
        if (!is.null(log)) log$warn("Item Failed: {conditionMessage(e)}")
        NA
      })
    })

    results[start_index:end_index] <- batch_results
    pb$tick()
  }
  results
}