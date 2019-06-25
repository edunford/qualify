# Temp API

example_data <- data.frame(id=c(1, 2), title=c("Farm", "House"), dropdown=c("M", "F"))

#' @filter cors
cors <- function(req, res) {
  
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
  res$setHeader("X-Total-Count", 1)
  example_data
}

#* An endpoint for getting specific records
#' @get /posts/<pid>
function(pid){
  jsonlite::unbox(example_data[example_data$id==pid,]) 
}
#' @put /posts/<pid>
function(req){
  print(req$postBody)
  jsonlite::fromJSON(req$postBody)
}
