##### Chlorophyll analysis, 11 Feb 2024
##### Script to filter and prepare chlorophyll data from the MOCHA dataset for remote sensing matchup analysis.

##### Load libraries
library(raster)
library(tidyverse)
library(sf)
library(lubridate)
library(ggplot2)

##### Read in MOCHA data and filter for points with chlorophyll data
oa <- clean_all %>% filter(depth_m <=15) %>% filter(distance_offshore <= 50) # Filter for points where chlorophyll exists, and at a depth <= 15 m (mixed layer) and within 10 km of shore
oa$date <- as.Date(oa$time_utc) %>% format("%Y-%m-%d")
oa$year <- year(oa$date)
chl <- oa %>% filter(!is.na(chl_ugL))

# Depth-specific chlorophyll means for site-days
chl_per_depth <- chl %>% group_by(dataset_id, latitude, longitude, depth_m, year, date) %>% summarize(
  chl = mean(chl_ugL, na.rm = TRUE))

# Depth-averaged chlorophyll for site-days
chl_mixed <- chl %>% group_by(dataset_id, latitude, longitude, year, date) %>% summarize(
  chl = mean(chl_ugL, na.rm = TRUE))

chl_mixed$date <- as.Date(chl_mixed$date, format = "%Y-%m-%d")
chl_sentinel <- chl_mixed %>% filter(date > '2019-06-08')

write.csv(chl_mixed, '/Users/rachelcarlson/Documents/Research/Postdoc-2022-present/RS_chlorophyll/Data/MOCHA_matchups.csv')
write.csv(chl_sentinel, '/Users/rachelcarlson/Documents/Research/Postdoc-2022-present/RS_chlorophyll/Data/MOCHA_matchups_sentinel.csv')

pco <- oa %>% filter(!is.na(pCO2_uatm) | (!is.na(pH_total & !is.na(ta_umolkg))))
pco_sum <- pco %>% group_by(dataset_id, latitude, longitude, year, date) %>% summarize(
  t = mean(t_C, na.rm = TRUE),
  sal = mean(sal_pss, na.rm = TRUE),
  ta = mean(ta_umolkg, na.rm = TRUE),
  ph = mean(pH_total, na.rm = TRUE),
  alk = mean(ta_umolkg, na.rm = TRUE),
  do = mean(do_umolkg, na.rm = TRUE),
  pco2 = mean(pCO2_uatm, na.rm = TRUE),
  chl = mean(chl_ugL, na.rm = TRUE)
  )
pco_recent <- pco_sum %>% filter(date > '2019-06-08')



