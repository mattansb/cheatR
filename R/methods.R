#' print cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param x output of \code{catch_em()}.
#' @param ... not used
#' @importFrom scales percent
#' @export
print.chtrs <- function(x,...) {
  x$results[] <- percent(x$results[])
  x$results[upper.tri(x$results)] <- ''

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

#' plot cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param object output of \code{catch_em()}.
#' @param weight_range range of edge values to plot
#' @param ... not used
#'
#' @import tidygraph
#' @import ggraph
#' @import ggplot2
#' @importFrom scales percent
#' @importFrom magrittr %>%
#' @export
graph_em <- function(object,weight_range = c(.7,1),...){
  results_graph <- summary(object) %>%
    as_tbl_graph() %>%
    activate(what = edges) %>%
    filter(!is.na(weight),
           weight > weight_range[1],
           weight < weight_range[2])

  ggraph(results_graph) +
    geom_edge_fan(aes(label = percent(weight)),
                  angle_calc = 'along',
                  label_dodge = unit(2.5, 'mm')) +
    geom_node_label(aes(label = name))
}

#' plot histogram of similarity scores
#'
#' @author Mattan S. Ben-Shachar
#' @param object output of \code{catch_em()}.
#' @param ... passed to \code{hist}
#' @export
hist.chtrs <- function(object,...) {
  hist(summary(object)[],
       main = 'Histogram of similarity scores',
       xlab = 'Similarity',
       ...)
}
