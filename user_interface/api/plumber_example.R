# Temp API

#' @filter cors
cors <- function(req, res) {
  
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }
  
}

#* A test endpoint for providing dummy data
#* @get /posts
function(req, res){
#  stuff <- list(title=title, gender=dropdown)
#  print(stuff)
  res$setHeader("Access-Control-Expose-Headers", "X-Total-Count")
  res$setHeader("X-Total-Count", 1)
  data.frame(id=c(1, 2), title=c("Farm", "House"), dropdown=c("M", "F"))
}
