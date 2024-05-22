suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggthemes)
  library(tidyr)
  library(lubridate)
  library(stringr)
  library(purrr)
  library(reshape2)
  library(zoo)
  library(tibble)
  # library(shinyjs)
})

rxs <- (1:24)[-c(6,12,24)]

nf <- c(-121L,-123L,-119L,-122L,-122L,-130L,-123L,-123L,-123L,-123L,-120L,-130L,
        -122L,-122L,-122L,-123L,-123L,-123L,-122L,-122L,-123L,-122L,-115L,-130L) %>% 
  set_names(1:24) %>% 
  as.list %>% 
  keep(names(.) %in% rxs)

tzone <- "Pacific/Auckland"

if(Sys.info()[[1]] == "Windows") path_to_input  <-  normalizePath("./data")
if(Sys.info()[[1]] == "Darwin")  path_to_input  <-  normalizePath("./data")
if(Sys.info()[[1]] == "Linux")   path_to_input  <-  normalizePath("./data")

files <- dir(path_to_input, pattern = "O\\d{8}.Rdata", full.names = T)
dates <- files %>% str_extract("\\d{8}") %>% ymd(tz = tzone) %>% as.Date(tz = tzone)
start <- ymd_hm(paste(last(dates), "0600"), tz = tzone)          # start
stop  <- ymd_hm(paste(last(dates), "2000"), tz = tzone)          # stop

df <- crossing(time = seq.POSIXt(start, stop, length = 2), receiver = rxs) %>% 
  mutate(power = NA_integer_, chan = NA_integer_)

nf_lines <- geom_hline(
  aes(yintercept = nf), colour = "grey50", linetype = "22",
  data = nf %>% unlist %>% cbind(names(.) %>% as.integer, .) %>% 
    as_tibble(.name_repair = "minimal") %>% set_names(c("receiver", "nf")))

plot_blank <- function(df, start, stop, TZ = tzone) {
  
  ggplot(data = df) + geom_blank() + facet_grid(receiver ~ .) + 
    scale_y_continuous(limits = c(-125, -75), 
                       breaks = seq(-120, -80, 40),
                       minor_breaks = NULL) +
    scale_x_datetime(timezone = TZ,
                     date_minor_breaks = "1 hour",
                     date_breaks = "2 hours",
                     date_labels = "%R",
                     limits = c(start - dminutes(3), stop + dminutes(3))) +
    theme_minimal() + xlab(NULL) + ylab(NULL) + coord_cartesian(expand = F) +
    theme(panel.spacing = unit(2, "mm"),
          panel.grid.major.x = element_blank(),	
          panel.grid.minor.x = element_line(linewidth = 0.5, colour = "grey50"),
          panel.grid.minor.y = element_blank(),	
          panel.grid.major.y = element_blank()) + 
    nf_lines
}

placeholder <- plot_blank(df, start, stop)

img_path <- function(fname) {
  paste(normalizePath(file.path('./images'), winslash = "/", mustWork = T), 
        fname, sep = "/")
}

img_files <- function(freq, date) {
  dir(normalizePath(file.path('./images'), winslash = "/", mustWork = T),
      pattern = paste0(paste(freq, "\\d{2}", date, sep = "_"), ".png"))
}

img_namer <- function(in_fr, rv_ch, in_dt) {
  paste0(paste(
    sep = "_", in_fr, 
    rv_ch %>% as.numeric %>% median %>% as.integer %>% sprintf("%02d",.), 
    in_dt %>% as.character), ".png")
}

logger <- function(...) {
  message(paste(now(tz = tzone), ...))
  cat(paste(now(tz = tzone), ..., "\n"), file  = "log.txt", append = TRUE)
}

