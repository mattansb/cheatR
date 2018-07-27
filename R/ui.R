ui_gce <- fluidPage(

  # Application title
  titlePanel("Gotta Catch 'em All"),

  # Sidebar with a slider input for number of bins

  sidebarLayout(
    sidebarPanel(

      h3("Selected Documents"),

      fileInput("input_doc_list","Select Documents Files",
                multiple = TRUE),

      tableOutput("output_doc_list"),

      numericInput('n_grams',"n-grams (change only if you know what you're doing!)",value = 10, min = 2),

      sliderInput("weight_range","Similarity coeffs to plot",min = 0,max = 1,value = c(0.4,1))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      h3("Results"),

      tableOutput("output_doc_matrix"),

      plotOutput('output_graph')
    )
  )
)