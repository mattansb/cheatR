#' Run \code{catch_em} with \code{shiny}
#'
#' @author Almog Simchon
#'
#' @import shiny
#' @export
catch_em_app <- function() {
  # Run the application
  shinyApp(ui = ui_gce, server = server_gce)
}

ui_gce <- fluidPage(

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

      numericInput('n_grams',"n-grams (change only if you know what you're doing!)",value = 10, min = 2, width = '50%'),

      sliderInput("weight_range","Similarity coeffs to plot",min = 0,max = 1,value = c(0.4,1)),

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

#' @import tidygraph
#' @import ggraph
#' @import ggplot2
#' @import stringr
#' @importFrom scales percent
server_gce <- function(input, output) {
  first.word <- reactive({
    function(my.string){
      unlist(stringr::str_split(my.string, "[.]"))[[1]][1]
    }
  })

  catch_results <- reactive({
    if (is.null(input$input_doc_list))
      return(NA)

    res <- catch_em(input$input_doc_list$datapath, n_grams = input$n_grams)

    alias_docs <- sapply(input$input_doc_list$name, first.word())
    alias_docs <- alias_docs[input$input_doc_list$datapath %in% colnames(res$results)]

    colnames(res$results) <- rownames(res$results) <- alias_docs
    return(res)
  })

  output$output_doc_list <- renderTable({
    if (is.na(catch_results()))
      return(data.frame())

    data.frame(ID = sapply(input$input_doc_list$name, first.word()),
               Document = input$input_doc_list$name)

  })

  output$output_doc_matrix <- DT::renderDataTable({
    if (is.na(catch_results()))
      return(data.frame())

    for_mat <- catch_results()$results

    round(for_mat,3)
  }, rownames = TRUE, extensions = 'Buttons',
  options = list(dom = 'Bfrtip',
                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print'))
  )


  output$output_graph <- renderPlot({
    if (is.na(catch_results()))
      return(ggplot() + theme_void())

    results_graph <- as_tbl_graph(catch_results()$results) %>%
      activate(what = edges) %>%
      filter(!is.na(weight),
             weight >= input$weight_range[1],
             weight <= input$weight_range[2])

    ggraph(results_graph) +
      geom_edge_fan(aes(label = percent(weight)),
                    angle_calc = 'along',
                    label_dodge = unit(2.5, 'mm')) +
      geom_node_label(aes(label = name)) +
      theme_void()
  })
}
