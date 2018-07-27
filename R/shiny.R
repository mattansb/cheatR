#' @import shiny
#' @import tidygraph
#' @import ggraph
#' @import ggplot2
#' @export
catch_em_app <- function(...) {
  # Run the application
  shinyApp(ui = ui_gce, server = server_gce)
}

