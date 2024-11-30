library(bslib)
library(ggplot2)

server <- function(input, output, session) {
  # Reactive value to track whether streaming is active
  is_streaming <- reactiveVal(FALSE)

  # Start button observer
  observeEvent(input$start, {
    is_streaming(TRUE)  # Start streaming
  })

  # Stop button observer
  observeEvent(input$stop, {
    is_streaming(FALSE)  # Stop streaming
  })

  # Reactive real-time data generation
  reactiveData <- reactive({
    # Only generate data if streaming is active
    if (is_streaming()) {
      invalidateLater(1000, session)  # Refresh every second
      num_points <- ifelse(is.null(input$num_points) || input$num_points <= 0, 50, input$num_points)
      print(paste("Generating data with", num_points, "points"))
      data <- data.frame(x = 1:num_points, y = rnorm(num_points))
      print(head(data))  # Debugging output
      data
    } else {
      # Return an empty data frame when not streaming
      data.frame(x = numeric(0), y = numeric(0))
    }
  })

  # Plot the data
  output$realTimePlot <- renderPlot({
    data <- reactiveData()
    if (nrow(data) > 0) {
      ggplot(data, aes(x = x, y = y)) +
        geom_line(color = "blue") +
        labs(title = "Real-Time Data", x = "Index", y = "Value") +
        theme_minimal()
    } else {
      ggplot() + 
        labs(title = "Streaming Stopped", x = NULL, y = NULL) +
        theme_minimal()
    }
  })
}

