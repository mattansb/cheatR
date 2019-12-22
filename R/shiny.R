#' Run \code{catch_em} with \code{shiny}
#'
#' @author Almog Simchon
#'
#' @import shiny
#' @import ggplot2
#' @export
catch_em_app <- function() {
  if(!require(shiny))
    stop("This function requares 'shiny' to work. Please install it.")
  if(!require(DT))
    stop("This function requares 'DT' to work. Please install it.")
  if(!require(ggplot2))
    stop("This function requares 'ggplot2' to work. Please install it.")

  # Run the application
  shinyApp(ui = ui_gce(), server = server_gce)
}

ui_gce <- function(){
  fluidPage(
    # Application title
    titlePanel(paste0("Gotta Catch 'em All (v",packageVersion("cheatR"),')')),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(

        # img(src=paste0(dirname(rstudioapi::getSourceEditorContext()$path), "cheatrball.png"),
        #     align = "right", width="20%"),

        h3("Selected Documents"),

        fileInput("input_doc_list","Select Documents Files",
                  multiple = TRUE),

        tableOutput("output_doc_list"),

        numericInput('n_grams',"n-grams (change only if you know what you're doing!)",value = 10, min = 2),

        sliderInput("weight_range","Similarity coeffs to plot",min = 0,max = 1,value = c(0.4,1)),

        checkboxInput("lonely", "Remove lonely files?", value = TRUE),

        tags$div(class="header", checked=NA,

                 list(
                   HTML("Want more info and Pokemon references?"),tags$a(href="https://github.com/mattansb/cheatR", "over here")
                 )
        )
      ),

      # Show a plot of the generated distribution
      mainPanel(
        h3("Results"),

        DT::dataTableOutput("output_doc_matrix"),

        plotOutput('output_graph')
      )
    )
  )
}

server_gce <- function(input, output) {
  catch_results <- reactive({
    if (is.null(input$input_doc_list))
      return(NA)

    res <- catch_em(input$input_doc_list$datapath, n_grams = input$n_grams)

    colnames(res) <- rownames(res) <- basename(input$input_doc_list$name)
    return(res)
  })

  output$output_doc_list <- renderTable({
    if (is.null(input$input_doc_list))
      return(data.frame())

    data.frame(Document = input$input_doc_list$name)
  })

  output$output_doc_matrix <- DT::renderDataTable({
    if (is.na(catch_results()))
      return(data.frame())

    for_mat <- summary(catch_results())

    round(for_mat,3)
  },
  rownames = TRUE,
  extensions = 'Buttons',
  options  = list(dom = 'Bfrtip',
                  buttons = c('copy', 'csv', 'excel', 'pdf', 'print'))
  )


  output$output_graph <- renderPlot({
    if (is.na(catch_results()[1]))
      return(ggplot() + theme_void())

    graph_em(catch_results(),
             weight_range = input$weight_range,
             remove_lonely = input$lonely) +
      theme_void()
  })
}

