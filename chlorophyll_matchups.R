##### Chlorophyll analysis, 11 Feb 2024
##### Script to filter and prepare chlorophyll data from the MOCHA dataset for remote sensing matchup analysis.

##### Load libraries
library(raster)
library(tidyverse)
library(sf)
library(lubridate)
library(ggplot2)

##### Read in MOCHA data and filter for points with chlorophyll data
oa <- clean_all
oa$date <- as.Date(oa$time_utc) %>% format("%y-%m-%d")
chl <- oa %>% filter(!is.na(chl_ugL)) %>% filter(depth_m <= 10) # Filter for points where chlorophyll exists, and at a depth <= 15 m (mixed layer)

# Depth-specific chlorophyll means for site-days
chl_per_depth <- chl %>% group_by(dataset_id, latitude, longitude, depth_m, date) %>% summarize(
  chl = mean(chl_ugL, na.rm = TRUE))

# Depth-averaged chlorophyll for site-days
chl_mixed <- chl %>% group_by(dataset_id, latitude, longitude, date) %>% summarize(
  chl = mean(chl_ugL, na.rm = TRUE))

write.csv(chl_mixed, '/Users/rachelcarlson/Documents/Research/Postdoc-2022-present/RS_chlorophyll/MOCHA_matchups.csv')

sf_chl_mixed <- st_as_sf(chl_mixed, coords = c("longitude", "latitude"))
st_write(sf_chl_mixed, "/Users/rachelcarlson/Documents/Research/Postdoc-2022-present/RS_chlorophyll/Data/MOCHA_matchups.shp")

