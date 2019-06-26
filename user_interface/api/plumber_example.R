# Temp API

source(here::here("R/qualify.R"))
require(tidyverse)



# Main Function Calls -----------------------------------------------------

import_data_state <- function(.project_name = "test_db"){
  sql_instance(.project_name) %>% 
    dplyr::tbl(".unit") %>% 
    dplyr::collect() 
}


api_data_call = function(unit = "",.project_name = "test_db"){
  con = sql_instance(.project_name) 
  all_tbls = grep("field_",dplyr::src_tbls(con),value = T)
  api_order = as.list(rep(NA,length(all_tbls)))
  names(api_order) = all_tbls
  for(t in all_tbls){
    api_order[[t]] = 
      dplyr::tbl(con,t) %>% 
      dplyr::filter(.unit == unit) %>% 
      dplyr::collect() %>% 
      dplyr::rename(id = .unit)
  }
  return(api_order) # Send back the request
}


# Plumber API Features ----------------------------------------------------

# Call all Available Units. 
master_data <- import_data_state()

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
#  stuff <- list(title=title, gender=dropdown)
#  print(stuff)
  res$setHeader("Access-Control-Expose-Headers", "X-Total-Count")
  res$setHeader("X-Total-Count", nrow(master_data))
  master_data
}

#* An endpoint for getting specific records
#' @get /posts/<pid>
function(pid){
  # jsonlite::unbox(.data[.data$id==pid,]) 
  jsonlite::unbox(as.data.frame(api_data_call(unit = pid)$field_var_1))
}

#' @put /posts/<pid>
function(req){
<<<<<<< HEAD
  entry = jsonlite::fromJSON(req$postBody)
  save(entry,file = "~/Desktop/test.Rdata")
=======
>>>>>>> 137d67c6fdc1737e85327079236384211e563f69
  jsonlite::fromJSON(req$postBody)
}

