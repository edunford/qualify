# Qualify Database API

source(here::here("R/qualify.R"))
require(tidyverse)

# TEMPORARY
db_location <- "~/Desktop/test_project/"

# Plumber API Features ----------------------------------------------------

#' @filter cors
cors <- function(req, res) {
  # !DON'T Touch!
  res$setHeader("Access-Control-Allow-Origin", "*")

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","GET,POST,PUT")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }

}

#* A test endpoint for providing dummy data
#' @get /posts
function(req, res){
  master_data <- import_data_state(.project_path = db_location)
  res$setHeader("Access-Control-Expose-Headers", "X-Total-Count")
  res$setHeader("X-Total-Count", nrow(master_data))
  master_data
}

#* An endpoint for getting specific records
#' @get /posts/<pid>
function(pid){
  jsonlite::unbox(api_data_call(unit = pid,.project_path = db_location))
}

#' @put /posts/<pid>
function(req){
  entry = jsonlite::fromJSON(req$postBody)
  # save(entry,file = "~/Desktop/test.Rdata")
  upload_data(entry,.project_path = db_location)
  jsonlite::fromJSON(req$postBody)
}




