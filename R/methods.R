#' @export
print.chtrs <- function(x, digits = 0, ...) {
  x_ <- x

  add_na <- is.na(x[])
  x[] <- paste0(100 * round(x[], 2 + digits), "%")
  x[add_na] <- NA
  x[upper.tri(x)] <- ''

  bad_read <- length(attr(x,"bad_read"))
  bad_ngrams <- nrow(attr(x,"bad_ngrams"))

  x <- unclass(x)
  attr(x, "bad_read") <- NULL
  attr(x, "bad_ngrams") <- NULL

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
#' @param object output of [catch_em()].
#' @param bad_files logical. Instead of the result matrix, should return instead
#'   the list of bad files (that did not compare / load)? Defaults to `FALSE`.
#' @param ... Not used.
#'
#' @export
summary.chtrs <- function(object, bad_files = FALSE, ...) {
  if (bad_files) {
    list(
      bad_read = attr(object, "bad_read"),
      bad_ngrams = attr(object, "bad_ngrams")
    )
  } else {
    object
  }
}

#' Plot cheatrs / histogram of similarity scores
#'
#' `plot` requires `ggraph` and `ggplot2` to work.
#'
#' @author Mattan S. Ben-Shachar
#'
#' @param x output of [catch_em()].
#' @param weight_range range of edge values to plot
#' @param ... passed to [ggraph::ggraph()], [ggplot2::geom_histogram] or
#'   [hist()].
#' @param remove_lonely should lonely nodes (with no edges) be removed from the
#'   graph?
#' @param digits Number of digits to round the percentage to.
#'
#' @export
plot.chtrs <- function(x,
                       weight_range = c(.4,1),
                       remove_lonely = TRUE,
                       digits = 0, ...){
  if(!requireNamespace("tidygraph"))
    stop("This function requares 'tidygraph' to work. Please install it.")
  if (!requireNamespace("ggraph"))
    stop("This function requares 'ggraph' to work. Please install it.")
  if (!requireNamespace("ggplot2"))
    stop("This function requares 'ggplot2' to work. Please install it.")

  if (dim(x)[1] < 3) {
    stop("Cannot plot a graph between only 2 documents.", call. = FALSE)
  }

  `%>%` <- tidygraph::`%>%`
  `%E>%` <- tidygraph::`%E>%`
  `%N>%` <- tidygraph::`%N>%`

  results_graph <- x %>%
    tidygraph::as_tbl_graph() %E>%
    tidygraph::filter(!is.na(.data$weight),
                      weight >= weight_range[1],
                      weight <= weight_range[2])

  if (remove_lonely) {
    results_graph <- results_graph %E>%
      tidygraph::filter(from != to) %N>%
      tidygraph::filter(
        1:tidygraph::n() %in%
          c(tidygraph::.E()$from, tidygraph::.E()$to)
      )
  }

  if (nrow(tidygraph::as_tibble(tidygraph::activate(results_graph, nodes))) == 0 |
      nrow(tidygraph::as_tibble(tidygraph::activate(results_graph, edges))) == 0) {
    stop("Cannot plot a graph without nodes/edges. Try changing 'weight_range'.",
         call. = FALSE)
  }

  ggraph::ggraph(results_graph, ...) +
    ggraph::geom_edge_fan(
      ggplot2::aes(label = paste0(100 * round(weight, 2 + digits), "%")),
      angle_calc = 'along',
      label_dodge = grid::unit(2.5, 'mm')
    ) +
    ggraph::geom_node_label(ggplot2::aes(label = name))
}

#' @export
#' @rdname plot.chtrs
graph_em <- plot.chtrs


#' @export
#' @rdname plot.chtrs
hist.chtrs <- function(x, ...) {
  if (requireNamespace("ggplot2")) {
    ggplot2::ggplot() +
      ggplot2::geom_histogram(ggplot2::aes(x = as.vector(x)), ...) +
      ggplot2::labs(main = 'Histogram of similarity scores',
                    x = 'Similarity')
  } else {
    hist(as.vector(x),
         main = 'Histogram of similarity scores',
         xlab = 'Similarity',
         ...)
  }
}
