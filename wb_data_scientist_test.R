# http://api.worldbank.org/v2/indicators/NY.GDP.MKTP.CD Documentation Sample
# code: SH.STA.ACSN,  data for all countries in the WDI starting 1960

library(lubridate)
library(jsonlite)
library(tidyverse)
library(XML)
library(highcharter)

# set parameters

country <- 'all'
indicator <- 'SH.STA.ACSN'

# create the data pull handler 

wb_api<- "http://api.worldbank.org/v2/" 
this_pull <- paste0(wb_api, 'countries/', country, '/indicators/', indicator) # , '?date=', startDate, ':', year(Sys.Date()))

# Fetch data
xml <- xmlParse(this_pull)
xml_list <- xmlToList(xml)

# Create a loop to pull all the data(page by page)

data <- data.frame()

for (i in 1: xml_list$.attrs['pages']){ # get the No. of pages
  
  page_i <- xmlToDataFrame(xmlParse(paste0(this_pull, '?page=', i)))
  
  data <- bind_rows(page_i, data)
}

# Data cleaning

data1 <- data %>%
  mutate(date = as.numeric(date)) %>% 
  filter(date >1959) %>% # get data from 1960 till now
  select(country, value, indicator, date) %>%
  mutate(value = round(as.numeric(value), digits = 2)) %>% # remove extra long decimals
  na.omit() # remove NAs

# Save the data for .rmd 
save(data1, file = 'C:/Users/wb516609/desktop/WB_DS_Test/data1.RData') # please remember to change directory

# Just a rough test on how the data look like
hchart(data1, "line", hcaes(x = date, y = value, group = country))
