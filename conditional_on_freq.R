rv$subset <- 
  rv$dat[[rv$freq %>% as.character]] %>%                     # filter out the freq
  mutate(time = round_date(time, "1 minute")) %>%            # aggregate by minute
  group_by(time, receiver) %>% 
  slice(which.max(power)) %>%                                # filter hp
  ungroup

# # fill in NAs for breaks in geom_line ----------------------------------------
# rv$subset <- 
#   rv$subset %>% 
#   complete(                                                
#     time = seq.POSIXt(rv$start, rv$stop, "1 min"),
#     receiver = rxs,
#     fill = list(power = NA_integer_, chan = NA_integer_))
# # cat(now(tz = tzone) %>% as.character, "Source: Freq data filtered and aggregated\n")

# extract chan info ------------------------------------------------------------
rv$chan <- rv$subset$chan %>% na.omit
logger("Source: Chan =", paste0(rv$chan %>% unique %>% sort, collapse = " & "))
rv$message <- paste("TX:", "CH", paste0(rv$chan %>% unique %>% sort, collapse = " & "))
cat(now(tz = tzone) %>% as.character, "Source: Display message updated\n")
