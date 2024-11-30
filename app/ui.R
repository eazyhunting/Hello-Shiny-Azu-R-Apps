library(shiny)

ui <- fluidPage(
  titlePanel("Real-Time Data Streaming"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        inputId = "refresh_rate",
        label = "Refresh Rate (seconds):",
        value = 1,
        min = 0.1,
        step = 0.1
      ),
      actionButton("start", "Start Streaming"),
      actionButton("stop", "Stop Streaming")
    ),
    mainPanel(
      plotOutput("realTimePlot")
    )
  )
)



