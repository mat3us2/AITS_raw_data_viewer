# AITS raw data viewer

R Shiny app for preprocessing and viewing raw data from the Automated Insect Tracking System

This app takes minimally preprocessed data from an array of 21 VHF receivers and plots it for review. The generated figures served to spot inconsistencies in the data (eg. bursts of RF noise) and detect receiver downtime.

Here's what the app's logic:
1. At runtime: app checks the contents of the `./data folder`, extracts the dates from files' timestamps, and populates the calendar selector ("Choose a date")

2. The user is expected to select a date from the date selector (Available dates: Oct, Nov, or Dec 2017). The data are most dense around Nov 10 -- Nov 19, and 173330 and 173950 are the most interesting frequencies, including recorded movements of 173950 on 2017-11-02.

3. Once the date is selected the app -- based on the subset of the data file -- prepopulates the frequency selector ("Choose a frequency"); the frequencies (kHz) serve as IDs and correspond to individual transmitters. 173330 and 173950 are the most interesting frequencies, including recorded movements of 173950 on 2017-11-02.

4. Once a combination od date and frequency is chosen, several things happen:

+ the `./images` folder is checked for the corresponding figure file to avoid re-generating it (which is the most time-consuming step)
  + if the figure file is absent, the figure is generated, saved to `./images`, and displayed in the app window (this is accompanied by on-screen messages, console output, and log messages)
  + If the figure file is present, it is loaded from disk and displayed (loading a figure file from disk takes much less time than generating it -- some figures may contain over half a million data points)

Console output is intended for debugging and app state monitoring -- some combos of date and frequency take longer to generate. All messaging is logged to `./log.txt`.

Run with `shiny::runGitHub('AITS_raw_data_viewer', 'mat3us2')`.

Dependencies:
`dplyr`
`ggplot2`
`ggthemes`
`tidyr`
`lubridate`
`stringr`
`purrr`
`reshape2`
`zoo`
`tibble`
`shiny`

*Copyright notice: This software and accompanying data are non-licensed and serve a demonstration purpose only.*
