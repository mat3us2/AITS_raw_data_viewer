rv$start <- ymd_hm(paste(rv$date, "0600"), tz = tzone)       # start
logger("Source: Start time set to", rv$start %>% as.character)

rv$stop  <- ymd_hm(paste(rv$date, "2000"), tz = tzone)       # stop
logger("Source: Stop  time set to", rv$stop %>% as.character)

rv$dummy <- 
  crossing(time = seq.POSIXt(rv$start, rv$stop, length = 2), # dummy data
           receiver = rxs) %>% 
  mutate(power = NA_integer_, chan = NA_integer_)
  cat(now(tz = tzone) %>% as.character, "Source: Dummy data generated\n")

rv$blank_plot <- plot_blank(rv$dummy, rv$start, rv$stop)     # blank plot
cat(now(tz = tzone) %>% as.character, "Source: Blank plot generated\n")

load(files[dates == rv$date])                                # load daily file
cat(now(tz = tzone) %>% as.character, "Source: Daily file loaded\n")

rv$nf <- nf %>% keep(names(.) %in% unique(dat$receiver))     # update nf
cat(now(tz = tzone) %>% as.character, "Source: Noise floor object updated\n")

rv$dat <- dat %>%                                            # filter frequencies
  filter(freq %in% seq(172990L, 174010L, by = 5L), chan != 99L) %>%
  select(-code) %>% 
  split(., .$receiver) %>%                                   # split by receiver
  map2(rv$nf, ~filter(.x, .x$power >= .y + 2)) %>%           # filter by nf
  bind_rows() %>%
  split(., .$freq)                                           # split by freq
logger("Source: Daily data file filtered")
