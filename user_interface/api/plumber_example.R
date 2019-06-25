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

#* A meaningless input
#* @post /posts
function(req, title, dropdown){
  stuff <- list(title=title, gender=dropdown)
  print(stuff)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /happy
function(a, b){
  as.numeric(a) + as.numeric(b)
}
