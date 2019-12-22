#' Print Cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param x output of \code{catch_em()}.
#' @param ... not used
#'
#' @export
print.chtrs <- function(x,...) {
  x_ <- x

  add_na <- is.na(x[])
  x[] <- paste0(100 * round(x[], 2), "%")
  x[add_na] <- NA
  x[upper.tri(x)] <- ''

  bad_read <- length(attr(x,"bad_read"))
  bad_ngrams <- nrow(attr(x,"bad_ngrams"))

  print(unclass(x), quote = F, right = T)
  if (bad_read > 0) {
    cat('\n', bad_read, ' files could not be read.')
  } else {
    cat('\nAll files read successfully.')
  }

  if (!is.null(bad_ngrams)) {
    cat('\n', bad_read, ' comparisons failed.')
  } else {
    cat('\nAll files compared successfully.')
  }

  invisible(x_)
}

#' Summarise Cheatrs
#'
#' @author Mattan S. Ben-Shachar
#' @param x output of \code{catch_em()}.
#' @param bad_files logical. Instead of the result matrix, should return instead the list of bad files (that did not compare / load)? default \code{FALSE}
#'
#' @export
summary.chtrs <- function(object, bad_files = FALSE) {
  if (bad_files) {
    list(bad_read = attr(object, "bad_read"),
         bad_ngrams = attr(object, "bad_ngrams"))
  } else {
    object
  }
}

#' Plot Cheatrs
#'
#' @author Mattan S. Ben-Shachar
#'
#' @param object output of \code{catch_em()}.
#' @param weight_range range of edge values to plot
#' @param ... passed to \code{ggraph}.
#' @param remove_lonely should lonely nodes (with no edges) be removed from the graph?
#'
#' @import tidygraph
#' @import ggraph
#' @import ggplot2
#' @export
plot.chtrs <- function(object,weight_range = c(.4,1), remove_lonely = TRUE, ...){
  if(!require(tidygraph))
    stop("This function requares 'tidygraph' to work. Please install it.")
  if (!require(ggraph))
    stop("This function requares 'ggraph' to work. Please install it.")
  if (!require(ggplot2))
    stop("This function requares 'ggplot2' to work. Please install it.")

  if (dim(object)[1] < 3) {
    stop("Cannot plot a graph between only 2 documents.", call. = FALSE)
  }

  results_graph <- object %>%
    as_tbl_graph() %E>%
    filter(!is.na(weight),
           weight >= weight_range[1],
           weight <= weight_range[2])

  if (remove_lonely) {
    results_graph <- results_graph %E>%
      filter(from != to) %N>%
      filter(1:n() %in% c(.E()$from,.E()$to))
  }

  if (nrow(as_tibble(activate(results_graph,nodes))) == 0 |
      nrow(as_tibble(activate(results_graph,edges))) == 0) {
    stop("Cannot plot a graph without nodes/edges. Try changing 'weight_range'.", call. = FALSE)
  }

  ggraph(results_graph, ...) +
    geom_edge_fan(aes(label = paste0(100 * round(weight, 2), "%")),
                  angle_calc = 'along',
                  label_dodge = unit(2.5, 'mm')) +
    geom_node_label(aes(label = name))
}

#' @export
#' @rdname plot.chtrs
graph_em <- plot.chtrs

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
