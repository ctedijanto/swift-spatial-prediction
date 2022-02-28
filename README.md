# SWIFT spatial prediction

Code and public data to replicate analysis from the following preprint ([link](https://www.medrxiv.org/content/10.1101/2021.07.19.21260623v2)): *Tedijanto, Christine, et al. "Predicting future ocular* Chlamydia trachomatis *infection prevalence using serological, clinical, molecular, and geospatial data." medRxiv (2021).*

This work is a secondary analysis of the WASH Upgrades for Health in Amhara (WUHA) cluster-randomized controlled trial, one of the SWIFT trials [NCT02754583](https://clinicaltrials.gov/ct2/show/NCT02754583).

The statistical analysis plan for this work can be found on Open Science Framework: [https://osf.io/t48zb/](https://osf.io/t48zb/)

This repository has been assigned the following DOI: [10.5281/zenodo.5851642](https://doi.org/10.5281/zenodo.5851642)

## System requirements

Instructions and expected run times below are based on the following specifications:

```
>sessionInfo()
R version 4.0.2 (2020-06-22)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS 10.16
```

All analyses were run using the [RStudio IDE](https://www.rstudio.com).

For best replication results, this analysis can be run within a [Docker](https://www.docker.com/) container which is built on the [rocker](https://www.rocker-project.org/images/) `geospatial` image. Packages and versions are saved in the `renv.lock` file and installed when building the Docker image using [renv](https://rstudio.github.io/renv/articles/renv.html).

## Instructions

The first 3 `.Rmd` files (`01-data-prep.Rmd`, `02-gee-extract.Rmd`, and `03-merge-data.Rmd`) and code for Figures 1, 2A, S1A and S2A will not run as they rely on individual-level measurements (not made public at this time) and personally identifiable information (latitude and longitude coordinates). For the public dataset, coordinates have been altered so that exact locations remain unknown but relative location between communities has been preserved.

**To run within a Docker container:**

1. Clone this repository
2. Download and run Docker on your machine. Under Preferences > Resources > Advanced, increase memory to 8GB (some included packages require additional memory to compile)
3. Build the Docker image using following command in Terminal: `docker build -t <image name> <repository filepath>` 
	- The Docker build should take around 60 minutes including installation of all packages using `renv`
4. Launch an instance of the Docker image using the following command in Terminal:  `docker run -e USER=<username> -e PASSWORD=<password> --rm -p 8787:8787 -v <repository filepath>:/home/rstudio <image name>`
5. Navigate to the browser (`http://localhost:8787`). To access RStudio Server, enter the user ID and password specified in the Terminal command
6. Run code chunks or knit entire `.Rmd` files

**If not using Docker:**

1. Clone this repository
2. Use `renv::restore()` to install packages
3. Run code chunks or knit entire `.Rmd` files

## Expected output

The `output` folder contains HTML output for `.Rmd` files and saved model results from `05-prediction-models.Rmd` that can be used to directly create figures. 

Typical knit times for the `.Rmd` files are as follows:

* `04-feature-autocorrelation.Rmd`: 25 minutes
	- Decrease `n_permute_variog` (default = 1000) for shorter runtime
* `05-prediction-models.Rmd`: 5 minutes for all results in the main manuscript
	- 80 minutes for fitting all models evaluated in main manuscript **and** supporting information; modify `xx_grid` variables to select models to run
* `06-figures.Rmd`: 30 minutes
	- Decrease `n_permute_variog` (default = 1000) and/or `n_bs_cor` (default = 1000) for shorter runtime

Ensemble model output may vary from run to run; the parallel processing of the package makes it challenging to set seeds for exact replication. 

## Troubleshooting

**`sl3` download**

Downloading this package may throw an error due to exceeding Github's API rate limit. For more details, see the `tlverse` installation notes [here](https://tlverse.org/tlverse-handbook/tlverse.html#installtlverse). In step #1, note that `usethis::browse_github_pat()` is now defunct and has been replaced by `create_github_token()`.

**Automatic `knit`**

The automatic "knit" button in RStudio may not work, particularly when using RStudio Server or knitting `06-figures.Rmd`. If this occurs, knit manually using `rmarkdown::render(<Rmd filepath>)`