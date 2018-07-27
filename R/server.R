server_gce <- function(input, output) {
  catch_results <- reactive({
    if (is.null(input$input_doc_list))
      return(NA)

    res <- catch_em(input$input_doc_list$datapath, n_grams = input$n_grams)

    alias_docs <- paste0('Doc ',seq_along(input$input_doc_list$name))
    alias_docs <- alias_docs[input$input_doc_list$datapath %in% colnames(res$results)]

    colnames(res$results) <- rownames(res$results) <- alias_docs
    return(res)
  })

  output$output_doc_list <- renderTable({
    if (is.na(catch_results()))
      return(data.frame())

    data.frame(ID = paste0('Doc ',seq_along(input$input_doc_list$name)),
               Document = input$input_doc_list$name)

  })

  output$output_doc_matrix <- renderTable({
    if (is.na(catch_results()))
      return(data.frame())

    for_mat <- catch_results()$results

    round(for_mat,3)
  }, rownames = TRUE)


  output$output_graph <- renderPlot({
    if (is.na(catch_results()))
      return(ggplot() + theme_void())

    results_graph <- as_tbl_graph(catch_results()$results) %>%
      activate(what = edges) %>%
      filter(!is.na(weight),
             weight >= input$weight_range[1],
             weight <= input$weight_range[2])

    # Plot the graph
    ggraph(results_graph) +
      geom_edge_fan(aes(label = round(weight,2)),
                    angle_calc = 'along',
                    label_dodge = unit(2.5, 'mm')) +
      geom_node_label(aes(label = name)) + theme_void()
  })
}