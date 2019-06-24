# qual_build()

# Build the input requests for the basic input scheme. 


#' generate_module()
#' 
#' Build the input requests for the basic input scheme. 
#'
#' @param variable_name 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
#' 
#' generate_module(variable_name = "var_1",
#'                 caption = "This variable is about this ...",
#'                 evidence = text_field(), 
#'                 note = text_field(), 
#'                 publication_date = date_field(), 
#'                 code_var = c(1,2,3,4))
generate_module = function(variable_name = "",
                           caption = "",
                           ...){
  UseMethod("generate_module")
}


# @export 
generate_module = function(variable_name = "",
                           caption = "",
                           ...){
  obj = list(x = list(...))
  names(obj) = variable_name
  return(list(caption = caption,construction = obj, fields = sapply(obj[[1]],class)))
}


#' date_field
#'
#' Placeholder for date field entry parameter on the application module. 
#'
#' @return
#' @export
#'
#' @examples
date_field = function(placehold_date = "1900-01-01"){
  as.Date(placehold_date)
}


#' text_field
#'
#' Placeholder for text field entry parameter on the application module. 
#'
#' @param txt 
#'
#' @return
#' @export
#'
#' @examples
text_field = function(txt = ""){txt}


# Test
generate_module(variable_name = "var_1",
                caption = "This variable is about this ...",
                evidence = text_field(), 
                note = text_field(), 
                publication_date = date_field(), 
                code_var = c(1,2,3,4))



