### file description -----
# Configuration file
# for WUHA prediction
# Author: Christine Tedijanto christine.tedijanto@ucsf.edu
# Last updated: 07/17/2021
### ----------------------

### load package environment -----
#if (!require(renv)) install.packages('renv')
#renv::restore()

### load packages -----
# general
library(tidyverse)
library(devtools) # run packages from github
library(here)
here()

# plots
library(ggplot2)
library(ggpubr)
library(gridExtra) # grid.arrange
library(corrplot)
library(cowplot) # panel figures
library(gt) # tables

# api
library(httr)
library(jsonlite)

# spatial packages
library(rgee)
library(sf)
library(rgdal)
library(lwgeom)
library(raster)
library(geojsonio) # for ee_extract
library(exactextractr) # summarize raster values over polygonal areas
library(blockCV) # spatial cross-validation

# mapping packages
library(osmdata) # open street map
library(ggmap) # production version installed to address the issue described here: https://github.com/dkahle/ggmap/issues/287
library(ggrepel)
library(leaflet)

# prediction packages
library(origami) # testing package for cross-validation
library(sl3)
library(R6) # allow for creation of own Lrnrs

library(spaMM)
library(nnls)
library(glmnet)
library(mgcv) 
library(earth)
library(randomForest)
library(xgboost)

### local paths -----
data_path <- "../1-data"
figure_path <- "../2-figures"

### global variables -----
swift_crs <- 4326
survey_list <- c(0,12,24,36)
age_group_list <- c("0-5y", "6-9y", "10+y")
trach_ind <- c("prevalence_sero", "prevalence_pcr", "prevalence_clin")

# create vectors containing start and end dates of each month in study
# start with 2015 (year prior to baseline survey, which was conducted in December 2015)
start_dates <- as.character(seq(as.Date("2015-01-01"), length=12*4, by="months"))
end_dates <- as.character(seq(as.Date("2015-02-01"), length=12*4, by="months")-1)

# seropositives defined by following cutoffs
Pgp3_cutoff <- 1113
Ct694_cutoff <- 337

### mini-functions -----
`%ni%` <- Negate(`%in%`)
