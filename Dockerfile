FROM rocker/geospatial:4.0.2

# load packages using renv
#RUN R -e "install.packages(c('xgboost'))"
RUN R -e "install.packages(c('renv'))"
WORKDIR /project
COPY renv.lock renv.lock
RUN R -e "renv::consent(provided = TRUE)"
RUN R -e "renv::restore(prompt = FALSE)"

