# Wrapper to run the plumber api
library(plumber)
library(here)

r <- plumb(here("user_interface/api/plumber_example.R"))
r$run(port=8000)
