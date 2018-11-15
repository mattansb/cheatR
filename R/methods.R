#' print cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param x output of \code{catch_em()}.
#' @param ... not used
#' @export
print.chtrs <- function(x,...) {
  if ("scales" %in% rownames(installed.packages())) {
    x$results[] <- scales::percent(x$results[])
    x$results[upper.tri(x$results)] <- ''
  }

  print(x$results, quote = F, right = T)


  bad_read <- length(x$bad_files$bad_read)
  bad_ngrams <- nrow(x$bad_files$bad_ngrams)

  if (bad_read > 0) {
    cat('\n',bad_read,' files could not be read.')
  } else {
    cat('\nAll files read successfully.')
  }

  if (bad_ngrams > 0) {
    cat('\n',bad_read,' comparisons failed.')
  } else {
    cat('\nAll files compared successfully.')
  }

  invisible(x)
}

#' summarise cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param x output of \code{catch_em()}.
#' @param bad_files logical. Instead of the result matrix, should return instead the list of bad files (that did not compare / load)? default \code{FALSE}
#' @export
summary.chtrs <- function(object, bad_files = F) {
  if (bad_files) {
    object$bad_files
  } else {
    object$results
  }
}
