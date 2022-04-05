# SWIFT spatial prediction

This repository includes the deidentified data and R code for the following paper:

Tedijanto C, Aragie S, Tadesse Z, Haile M, Zeru T, Nash SD, Wittberg DM, Gwyn S, Martin DL, Sturrock HJ, Lietman TM, Keenan JD, Arnold BF. Predicting future community-level ocular *Chlamydia trachomatis* infection prevalence using serological, clinical, molecular, and geospatial data. PLoS neglected tropical diseases. 2022 Mar 11;16(3):e0010273. https://pubmed.ncbi.nlm.nih.gov/35275911/

https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0010273

This work is a secondary analysis of the WASH Upgrades for Health in Amhara (WUHA) cluster-randomized controlled trial, one of the SWIFT trials [NCT02754583](https://clinicaltrials.gov/ct2/show/NCT02754583).

The statistical analysis plan for this work can be found on Open Science Framework: [https://osf.io/t48zb/](https://osf.io/t48zb/)

This repository has been assigned the following DOI: [10.5281/zenodo.5851642](https://doi.org/10.5281/zenodo.5851642)

Should you have any questions about the files in this repository, please contact Christine Tedijanto at UCSF (christine.tedijanto@ucsf.edu).

## System requirements

Instructions and expected run times below are based on the following specifications:

```
>sessionInfo()
R version 4.0.2 (2020-06-22)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS 10.16
```

All analyses were run using the [RStudio IDE](https://www.rstudio.com).

For best replication results, we recommend running the analysis within a [Docker](https://www.docker.com/) container which is built on the [rocker](https://www.rocker-project.org/images/) `geospatial` image. Packages and versions are saved in the `renv.lock` file and installed when building the Docker image using [renv](https://rstudio.github.io/renv/articles/renv.html).

## Instructions

The first 3 `.Rmd` files (`01-data-prep.Rmd`, `02-gee-extract.Rmd`, and `03-merge-data.Rmd`) and code for Figures 1, 2A, S1A and S2A will not run as they rely on individual-level measurements (not made public at this time) and personally identifiable information (latitude and longitude coordinates). For the public dataset, coordinates have been altered so that exact locations remain unknown but relative location between communities has been preserved.

1. Clone this repository
2. Download and run Docker on your machine. Under Preferences > Resources > Advanced, increase memory to at least 4GB -- this may need to be increased if running additional prediction models
3. Build the Docker image (example command in Terminal: `docker build -t <image name> <repository filepath>`)
	- The Docker build should take around 60 minutes including installation of all packages using `renv`
4. Launch an instance of the Docker image (example command in Terminal: `docker run -e USER=<username> -e PASSWORD=<password> --rm -p 8787:8787 -v <repository filepath>:/home/<username> <image name>`)
5. Navigate to the browser (e.g. `http://localhost:8787`) and enter the user ID and password specified in the Terminal command to access RStudio Server
6. Run code chunks or knit entire `.Rmd` files

## Expected output

The `output` folder contains HTML output for `.Rmd` files and saved model results from `05-prediction-models.Rmd` that can be used to directly create figures. 

Typical knit times for the `.Rmd` files are as follows:

* `04-feature-autocorrelation.Rmd`: 25 minutes
	- Decrease `n_permute_variog` (default = 1000) for shorter runtime
* `05-prediction-models.Rmd`: 5 minutes for all results in the main manuscript
	- 80 minutes for fitting all models evaluated in main manuscript **and** supporting information; modify `xx_grid` variables to select models to run
* `06-figures.Rmd`: 30 minutes
	- Decrease `n_permute_variog` (default = 1000) and/or `n_bs_cor` (default = 1000) for shorter runtime

Runtimes may be increased by 5-10 minutes on RStudio Server. Ensemble model output may vary from run to run; the parallel processing of the package makes it challenging to set seeds for exact replication. 

## Troubleshooting

**`sl3` download**

Downloading this package may throw an error due to exceeding Github's API rate limit. For more details, see the `tlverse` installation notes [here](https://tlverse.org/tlverse-handbook/tlverse.html#installtlverse). In step #1, note that `usethis::browse_github_pat()` is now defunct and has been replaced by `create_github_token()`.

**Automatic `knit`**

The automatic "knit" button in RStudio may not work, particularly when using RStudio Server or knitting `06-figures.Rmd`. If this occurs, knit manually using `rmarkdown::render(<Rmd filepath>)`