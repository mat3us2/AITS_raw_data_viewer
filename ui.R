library(shiny)

invalid_dates <- setdiff(
  as.character(seq.Date(as.Date("1900-01-01"), today() , by = 1)),
  as.character(ymd(substr(fs::path_ext_remove(dir("data")), 2, 9)))
)

shinyUI(
  fixedPage(
    title = "BOP data viewer",
    theme = "bootstrap.css",
    fixedRow(
      column(4,
             dateInput("date", 
                       label = "Choose a date:", 
                       value = "2017-10-01", 
                       min = "2017-10-01",
                       max = "2017-12-31",
                       datesdisabled = invalid_dates,
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
