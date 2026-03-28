library(glue)


create_logger <- function(log_dir = "logs", prefix = "pipeline") {
  if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)
  log_file <- file.path(
    log_dir,
    paste0(prefix, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log")
  )
  cat(glue("=== {prefix} started at {Sys.time()} ===\n\n"),
      file = log_file, append = FALSE)
  write_line <- function(line, color_fn = NULL) {
    console_line <- if (!is.null(color_fn)) color_fn(line) else line
    cat(console_line)
    cat(line, file = log_file, append = TRUE)
  }
  make_level <- function(level, color_fn = NULL) {
    function(msg) {
      formatted <- glue(msg, .envir = parent.frame(n = 1))
      line <- glue("[{Sys.time()}] {level}: {formatted}\n")
      write_line(line, color_fn)
    }
  }
  list(
    info    = make_level("INFO"),
    warn    = make_level("WARN",  cli::col_yellow),
    error   = make_level("ERROR", cli::col_red),
    success = make_level("OK",    cli::col_green),
    section = function(title) {
      bar <- strrep("=", 60)
      line <- glue("\n{bar}\n  {title}\n{bar}\n")
      write_line(line)
    },
    close = function() {
      cat(glue("\n=== {prefix} ended at {Sys.time()} ===\n"),
          file = log_file, append = TRUE)
    },
    get_log_file = function() log_file
  )
}