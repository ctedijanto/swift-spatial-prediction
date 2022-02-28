### file description -----
# Configuration file
# for SWIFT spatial prediction
# Author: Christine Tedijanto christine.tedijanto@ucsf.edu
# Last updated: 02/28/2022
### ----------------------

### load packages -----
# general
library(tidyverse)
library(devtools) # run packages from github

# plots
library(ggplot2)
library(ggpubr) # stat_cor
library(gridExtra) # grid.arrange
library(corrplot)
library(cowplot) # panel figures
library(gt) # tables

# spatial
library(rgee)
library(sf)
library(rgdal)
library(lwgeom)
library(raster)
library(geojsonio) # ee_extract
library(exactextractr) # summarize raster values over polygonal areas

# mapping
library(osmdata) # open street map
library(ggmap) # production version installed to address the issue described here: https://github.com/dkahle/ggmap/issues/287
library(ggrepel)
library(ggsn) #for scale bars and north symbols
library(rnaturalearth) # for africa country outlines

# prediction
library(origami) # cross-validation folds
library(sl3)
library(R6) # allow for creation of own Lrnrs

library(blockCV) # spatial cross-validation

library(spaMM)
library(nnls)
library(glmnet)
library(mgcv) 
library(earth)
library(randomForest)
library(xgboost)

### global variables -----
swift_crs <- 4326
survey_list <- c(0,12,24,36)
age_group_list <- c("0-5y", "6-9y", "10+y")
trach_ind <- c("prevalence_sero", "prevalence_pcr", "prevalence_clin")

# create vectors containing start and end dates of each month in study
# start with 2015 (year prior to baseline survey, which was conducted at end of 2015 / start of 2016)
start_dates <- as.character(seq(as.Date("2015-01-01"), length=12*4, by="months"))
end_dates <- as.character(seq(as.Date("2015-02-01"), length=12*4, by="months")-1)

# seropositivity thresholds were defined using ROC cutoff from reference samples
# see Migchelsen, et al. Defining seropositivity thresholds for use in trachoma elimination studies. PLOS NTD 2017.
# https://doi.org/10.1371/journal.pntd.0005230
Pgp3_cutoff <- 1113
Ct694_cutoff <- 337

### mini-functions -----
`%ni%` <- Negate(`%in%`)

### local paths -----
data_path <- "data"
output_path <- "output"
