#' Run `catch_em()` with `shiny`
#'
#' Run `catch_em()` interactively.
#'
#' @param ... Not used.
#'
#' @author Almog Simchon
#'
#' @return A `shiny` app object.
#'
#' @examples
#'
#' if (interactive()) {
#'   catch_em_app()
#' }
#'
#' @importFrom utils packageVersion
#' @export
catch_em_app <- function(...) {
  if (isTRUE(!requireNamespace("shiny")))
    stop("This function requares 'shiny' to work. Please install it.")
  if (isTRUE(!requireNamespace("DT")))
    stop("This function requares 'DT' to work. Please install it.")
  if (isTRUE(!requireNamespace("ggplot2")))
    stop("This function requares 'ggplot2' to work. Please install it.")

  # Run the application
  shiny::shinyApp(ui = ui_gce(), server = server_gce)
}

ui_gce <- function() {
  shiny::fluidPage(
    # Application title
    shiny::titlePanel(paste0(
      "Gotta Catch 'em All (v", utils::packageVersion("cheatR"), ')'
    )),

    # Sidebar with a slider input for number of bins
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        # img(src=paste0(dirname(rstudioapi::getSourceEditorContext()$path), "cheatrball.png"),
        #     align = "right", width="20%"),

        shiny::h3("Selected Documents"),

        shiny::fileInput("input_doc_list", "Select Documents Files",
                         multiple = TRUE),

        shiny::tableOutput("output_doc_list"),

        shiny::numericInput(
          'n_grams',
          "n-grams (change only if you know what you're doing!)",
          value = 10,
          min = 2
        ),

        shiny::sliderInput(
          "weight_range",
          "Similarity coeffs to plot",
          min = 0,
          max = 1,
          value = c(0.4, 1)
        ),

        shiny::checkboxInput("lonely", "Remove lonely files?", value = TRUE),

        shiny::tags$div(
          class = "header",
          checked = NA,

          list(
            shiny::HTML("Want more info and Pokemon references?"),
            shiny::tags$a(href = "https://github.com/mattansb/cheatR", "over here")
          )
        )
      ),

      # Show a plot of the generated distribution
      shiny::mainPanel(
        shiny::h3("Results"),

        DT::dataTableOutput("output_doc_matrix", width = "80%"),

        shiny::plotOutput('output_graph')
      )
    )
  )
}

server_gce <- function(input, output) {
  catch_results <- shiny::reactive({
    if (isTRUE(is.null(input$input_doc_list)))
      return(NA)

    res <- suppressMessages(
      catch_em(input$input_doc_list$datapath,
               n_grams = input$n_grams,
               progress_bar = FALSE)
    )


    colnames(res) <-
      rownames(res) <-
      basename(input$input_doc_list$name)
    return(res)
  })

  output$output_doc_list <- shiny::renderTable({
    if (isTRUE(is.null(input$input_doc_list)))
      return(data.frame())

    data.frame(Document = input$input_doc_list$name)
  })

  output$output_doc_matrix <- DT::renderDataTable({
    if (isTRUE(is.na(catch_results()[1])))
      return(data.frame())

    round(catch_results(), 3)
  },
  rownames = TRUE,
  extensions = 'Buttons',
  options  = list(
    dom = 'Bfrtip',
    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
  ))


  output$output_graph <- shiny::renderPlot({
    if (isTRUE(is.na(catch_results()[1])) || isTRUE(nrow(catch_results()) < 3))
      return(ggplot2::ggplot() + ggplot2::theme_void())

    plot.chtrs(
      catch_results(),
      weight_range = input$weight_range,
      remove_lonely = input$lonely
    ) +
      ggplot2::theme_void()
  })
}

