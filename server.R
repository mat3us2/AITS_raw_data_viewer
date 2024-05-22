library(shiny)
shinyServer(function(input, output, session) {
# initial values ----
  output$dates <- reactive({ NA })                           # conditional panel
  outputOptions(output, "dates", suspendWhenHidden = FALSE)  # conditional panel
  rv <- reactiveValues()
  
# watch changes to date selector -----------------------------------------------
  observeEvent(input$date, {
    rv$date <- input$date
    logger("Date:   Date selected:",                         # debug
           rv$date %>% as.character)                         # debug
    
    if(rv$date %in% dates) {                                 # if daily file exists
      output$dates <- reactive({ rv$date %in% dates })       # for conditional panel
      cat(now(tz = tzone) %>% as.character,                  # debug
          "Date:   Condition for freq selector set to",      # debug
          rv$date %in% dates, "\n")                          # debug

      source("conditional_on_date.R", local = TRUE)          # generate objects
      
      rv$message <- character(0)                             # clear message field
      cat(now(tz = tzone) %>% as.character,
          "Date:   Display message cleared\n")
      updateSelectInput(session,                             # update freq selection
                           inputId = "freq",
                           choices = names(rv$dat),
                           selected = character(0))
      cat(now(tz = tzone) %>% as.character,                  # debug
          "Date:   Updating freq selector\n")                # debug
      
    } else {                                                 # if NO daily file exists
      output$dates <- reactive({ rv$date %in% dates })       # for conditional panel
      cat(now(tz = tzone) %>% as.character,                  # debug
          "Date:   Condition for freq selector set to",      # debug
          rv$date %in% dates, "\n")                          # debug
      rv$message <- paste("No data. Pick a different date.") # 'no data'message
      cat(now(tz = tzone) %>% as.character,
          "Date:   Display message cleared\n")
      updateSelectInput(session,                             # update freq selection
                           inputId = "freq",
                           choices = NULL,
                           selected = character(0))
      cat(now(tz = tzone) %>% as.character,                  # debug
          "Date:   Updating freq selector\n")                # debug
    }
  
    output$message <- renderText({ rv$message })             # display message
    cat(now(tz = tzone) %>% as.character,
        "Date:   Display message rendered\n")
    # rv$freq <- character(0)                                # reset freq
    message("Date:   Cached freq set to NULL")               # debug
  }, ignoreNULL = F, ignoreInit = T, 
     once = F, suspended = F, priority = 3L
  )
  
# watch changes to freq selector for plot -------------------------------------- 
  #### This block can be accelerated by skipping the processing of frequency data
  #### if relevant image file exists; one of the outcomes of this is processing 
  #### is the channel unique to the frequency observed; this can be accomplished
  #### by looking up the unique frequency & channel combination in a predefined 
  #### object, generating the relevant filename, and checking its existence; on
  #### TRUE the processing of the data file can be skipped.
  #### DONE (workaround)
  #### SNIPPET: observeEvent(reactiveValuesToList(input), { ... } )
  #### SNIPPET: makeReactiveBinding(...)
  observeEvent(input$freq, {
    # rv$freq <- isolate(input$freq)
    rv$freq <- input$freq
    logger("Freq:   Freq selected:", isTruthy(input$freq),   # debug
           rv$freq)                                          # debug

    if(!isTruthy(rv$freq)) {                                 # if freq is NULL
      if(file.exists(img_path('blank.png'))) {               # if blank.png exists
        rv$output_plot <- NULL                               # NULL output
        # rv$output_plot <- placeholder                      # placeholder output
      } else { rv$output_plot <- placeholder }               # to generate blank.png
    } else {
      existing_files <- img_files(rv$freq, rv$date)          # freq & date img files
      if(length(existing_files) > 0) {                       # any?
        rv$chan <-                                           # extract chan from filename
          existing_files %>% 
          str_subset(rv$freq %>% as.character) %>% 
          str_subset(rv$date %>% as.character) %>% 
          str_extract("_\\d{2}_") %>% 
          str_extract("\\d{2}") %>% 
          as.integer
        rv$message <- 
          paste("TX:", "CH", 
                paste0(rv$chan %>% unique %>% sort, 
                       collapse = " & "))
        cat(now(tz = tzone) %>% as.character,
            "Source: Display message updated\n")
      } else {
        if(as.character(rv$freq) %in% names(rv$dat)) {       # if daily file exists
          source("conditional_on_freq.R", local = TRUE)      # pluck out freq data
        }}}                                                  # source conditional_on_freq.R
    
    # generate png file name -------------------------------------------------------
    if(!isTruthy(rv$date) || !isTruthy(rv$freq)) {           # at launch or on no-data day
      rv$file_name <- 'blank.png'
    } else {                                                 # on data day
      rv$file_name <- img_namer(rv$freq, rv$chan, rv$date)
    }
    
    # generate png file path -------------------------------------------------------
    rv$file_path <- img_path(rv$file_name)
    logger("Freq:   Filename:", rv$file_name)
    
    if(file.exists(rv$file_path)) {                          # if image file exists
      rv$file_action <- "loaded"                             # setup image message
      
      # generate image file message --------------------------------------------------
      if(rv$file_name == "blank.png") {
        rv$img_file <- character(0)                          # ignore if blank.png
        cat(now(tz = tzone) %>% as.character, 
            "Freq:   File message generated: '", 
            rv$img_file, "'\n")
        
      } else { 
        rv$img_file <- paste(rv$file_action, rv$file_name)   # setup image message
        cat(now(tz = tzone) %>% as.character,
            "Freq:   File message generated: '", 
            rv$img_file, "'\n")
      } # image file message
      
      # generate existing image data for browser -------------------------------------
      rv$img_data <-                                         # return a file path
        list(src = rv$file_path,                             #
             alt = paste(rv$file_action, rv$file_name))      #
      cat(now(tz = tzone) %>% as.character, 
          "Freq:   Image loaded\n")
      
      # generate png image -----------------------------------------------------------
    } else { # generate png image
      if(!rv$file_name == "blank.png") {
        suppressWarnings({
          rv$output_plot <- 
          rv$blank_plot + 
          geom_point(aes(time , power), size = 0.25,         # generate plot
          stroke = 0,
          data = rv$subset %>% na.omit)
        })
        cat(now(tz = tzone) %>% as.character,
            "Source: Plot object generated\n")
      }
      
      png(rv$file_path, width = 1000, height = 800)          # generate image file
      rv$output_plot %>% print                               #
      dev.off()                                              #
      #
      rv$file_action <- "generated"                          # setup image message
      rv$img_file <- paste(rv$file_action, rv$file_name)     # setup image message
      cat(now(tz = tzone) %>% as.character,
          "Freq:   File message generated: '",
          rv$img_file, "'\n")
      rv$img_data <-                                         # return a file path
        list(src = rv$file_path,                             #
             contentType = 'image/png',                      #
             width = 1000,                                   #
             height = 800,                                   #
             alt = paste(rv$file_action, rv$file_name))      #
      cat(now(tz = tzone) %>% as.character,
          "Freq:   Image saved:", rv$file_name, "\n")
    } # generate image file
    
    # generate outputs ------------------------------------------------------------- 
    # output$plot <- renderPlot({ rv$output_plot })          # render the plot
    cat(now(tz = tzone) %>% as.character,
        "Output: Plot rendered\n")
    output$message <- renderText({ rv$message })             # display message
    cat(now(tz = tzone) %>% as.character,
        "Output: Display message rendered: '",
        rv$message, "'\n")
    output$image <- renderImage({ rv$img_data },             # render plot
                                deleteFile = FALSE)
    cat(now(tz = tzone) %>% as.character,
        "Output: Image passed to browser\n")
    output$img_file <- renderText({ rv$img_file })           # display file message
    cat(now(tz = tzone) %>% as.character,
        "Output: File message rendered: '", 
        rv$img_file, "'\n")
    # rv$freq <- character(0)                                # reset freq
    # message("Freq:   Cached freq set to NULL")             # debug
  }, ignoreNULL = T, ignoreInit = F, once = F, 
     suspended = F, priority = 2L
  )
}
)
