library(shiny)

shinyUI(
  fixedPage(
    title = "BOP data viewer",
    theme = "bootstrap.css",
    fixedRow(
      column(4,
             dateInput("date", "Choose a date:", value = NULL, 
                       min = min(dates),
                       max = max(dates),
                       weekstart = 1L)
      ),
      column(4,
             conditionalPanel(
               condition = "output.dates", {
                 selectInput(
                   inputId = "freq",
                   label = "Choose a frequency:",
                   choices = character(0),
                   selected = character(0))
               })),
      column(4,
             br(),
             p(h4(span(style = "color:#808080", # strong(em(
                       textOutput("message"))))
      )),
    fixedRow(
      column(12, 
                         tabPanel("Image",
                                  imageOutput("image"))
    )),
    fixedRow(
      column(12, 
             br(), br(), br(), br(), br(), br(), br(),
             br(), br(), br(), br(), br(), br(), br(),
             br(), br(), br(), br(), br(), br(), 
             span(style = "color:#DDDDDD", textOutput("img_file"))
      ))
  )
)
