# Wrapper to run the plumber api
library(plumber)

r <- plumb("plumber_example.R")
r$run(port=8000)
