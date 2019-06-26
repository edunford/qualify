# Qualify Database API
source(here::here("R/qualify.R"))
require(tidyverse)


# Main Function Calls -----------------------------------------------------

import_data_state <- function(.project_name = "test_db"){
  sql_instance(.project_name) %>%
    dplyr::tbl(".unit") %>%
    dplyr::collect()
  
  # ADD SUMMARY INFORMATION HERE...
}


api_data_call = function(unit = "",.project_name = "test_db"){
  con = sql_instance(.project_name)
  all_tbls = grep("v",dplyr::src_tbls(con),value = T)
  api_order <- c()
  for(t in all_tbls){
    dplyr::tbl(con,t) %>%
      dplyr::filter(.unit == unit) %>%
      dplyr::arrange(desc(timestamp)) %>% 
      dplyr::select(-.unit) %>% 
      dplyr::collect() %>% 
      dplyr::slice(1) %>% 
      {colnames(.) = paste0(t,"_",colnames(.));.} %>% 
      dplyr::bind_cols(api_order,.) -> api_order
  }
  api_order$id = unit
  return(as.data.frame(api_order)) # Send back the request
}


upload_data = function(entry,.project_name = "test_db"){
  # Process entry records for resubmission into the data element. 
  id = entry$id 
  entry["id"] = NULL
  tags = stringr::str_remove_all(stringr::str_extract_all(names(entry),"v\\d_",simplify = T),"_") 
  vars = stringr::str_remove_all(names(entry),"v\\d_")
  to_record <- 
    tibble::tibble(.tag = tags,vars,entry = unlist(entry,use.names = F)) %>% 
    tidyr::spread(vars,entry) %>% 
    dplyr::mutate(.unit=id)
  
  # Loop through tags and draw out relevant features
  for(t in to_record$.tag){
    tmp = to_record %>% 
      dplyr::filter(.tag == t) %>%
      dplyr::select(-.tag) %>% 
      dplyr::mutate(timestamp = as.character(Sys.time()))
    
    # Append to existing data frame
    con = sql_instance(.project_name)
    DBI::dbWriteTable(conn=con$con, name = t, value = tmp,append=T) 
  }
}


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
  master_data <- import_data_state()
  res$setHeader("Access-Control-Expose-Headers", "X-Total-Count")
  res$setHeader("X-Total-Count", nrow(master_data))
  master_data
}

#* An endpoint for getting specific records
#' @get /posts/<pid>
function(pid){
  jsonlite::unbox(api_data_call(unit = pid))
}

#' @put /posts/<pid>
function(req){
  entry = jsonlite::fromJSON(req$postBody)
  upload_data(entry)
  jsonlite::fromJSON(req$postBody)
}
