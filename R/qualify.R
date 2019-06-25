# Build the input requests for the basic input scheme.

# FEATURES:
#   - streamlined and flexible field inputs
#   - sqlite table construction for all available fields given specified unit of analysis
#   - {Abby} Auto-import of existing codebook. 


#' qualify
#' 
#' Master function that initializes the data object
#'
#' @param project_name 
#' @param unit_of_analysis 
#'
#' @return
#' @export
#'
#' @examples
qualify = function(project_name = "test_db",
                   unit_of_analysis = c("a","b","c","d")){
  UseMethod("qualify")
}

#' @export
qualify = function(project_name = "test_db",
                   unit_of_analysis = c("a","b","c","d")){
  out = list(project_name = project_name,unit_of_analysis = unit_of_analysis)
  class(out) = c(class(out),"qualify_obj")
  return(out)
}


#' sql_instance
#' 
#' [AUX] Generate/call existing SQL database.
#'
#' @param db_name Name of the data base structure
#'
#' @return Connection to SQLite DB
#' @importFrom magrittr "%>%"
#'
#' @examples
sql_instance = function(db_name = "test_db") {
  # Build the Data Instance.
  if(!file.exists(paste0("Data/",db_name,".sqlite"))){
    dplyr::src_sqlite(paste0("Data/",db_name,".sqlite"),create=T) 
    con <- dplyr::src_sqlite(paste0("Data/",db_name,".sqlite"))
  }else{
    con <- dplyr::src_sqlite(paste0("Data/",db_name,".sqlite"))
  }
  return(con)
}


#' generate_module()
#' 
#' Build field inputs for coding entry. The function will run all 
#'
#' @param variable_name 
#' @param ... 
#'
#' @return
#' @importFrom magrittr "%>%"
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
generate_module = function(.data,
                           variable_name = "",
                           caption = "",
                           ...){
  UseMethod("generate_module")
}


#' @export
generate_module.qualify_obj = 
  function(.data,
           variable_name = "",
           caption = "",
           ...){
  # Connect to extant DB entry 
  con = sql_instance(.data$project_name)
  unit = .data$unit_of_analysis
  
  # Upload application instructions for proposed module.
  if(".input_state"  %in%  src_tbls(con)){
    current = dplyr::tbl(con,".input_state") %>% dplyr::select(-.id) %>% dplyr::collect() # Import the current input state
    tibble::tibble(var_name = variable_name,
                   caption = caption,
                   code_map = map_input(...)) %>%
      dplyr::bind_rows(current) %>% 
      unique(.) %>% 
      {dplyr::mutate(.,.id = paste0("v",nrow(.):1))} %>% 
      dplyr::select(.,.id,dplyr::everything()) %>% 
      dplyr::arrange(.id) %>% 
      dplyr::copy_to(dest=con,df = ., name = ".input_state",overwrite = T,temporary = F)
  } else{
    tibble::tibble(.id = "v1",
                   var_name = variable_name,
                   caption = caption,
                   code_map = map_input(...)) %>% 
      dplyr::copy_to(dest=con,df = ., name = ".input_state",overwrite = T,temporary = F)
  }
  
  # Generate enmpy table for respective variable field
  input = map_input(...)
  names = sapply(stringr::str_split(stringr::str_split(input,";")[[1]]," = "),function(x) stringr::str_trim(x[1]))
  entry = dplyr::as_tibble(matrix(NA,ncol = length(names)))
  colnames(entry) = names
  entry %>% 
    tidyr::crossing(tibble::tibble(.unit=unit),.) %>% 
    dplyr::copy_to(dest=con,df = ., name = paste0("field_",variable_name),overwrite = T,temporary = F)
  
  return(invisible(.data)) # pass back initial qualify instructions (but can't see it)
}


#' drop_module
#' 
#' Drop current module entry.
#'
#' @param .data 
#' @param var_name 
#'
#' @return
#' @importFrom magrittr "%>%"
#' @export
#'
#' @examples
drop_module = function(.data,variable_name){
  UseMethod("drop_module")
}

#' @export
drop_module.qualify_obj = function(.data,variable_name){
  
  # Connect to extant DB entry 
  con = sql_instance(.data$project_name)
  
  # Drop from the input state
  if(".input_state"  %in%  dplyr::src_tbls(con)){
    tbl(con,".input_state") %>% 
      dplyr::collect() %>% 
      dplyr::filter(var_name!=variable_name) %>% 
      dplyr::copy_to(dest=con,df = ., name = ".input_state",
                     overwrite = T,temporary = F)
  }
  
  # Drop specific data table entry
  dplyr::copy_to(con,df=tibble::tibble(NA),name = paste0("field_",variable_name),overwrite = T)
  
  return(invisible(.data)) # pass back initial qualify instructions (but can't see it)
}


#' field_date
#'
#' Placeholder for date field entry parameter on the application module. 
#'
#' @return
#' @export
#'
#' @examples
field_date = function(placehold_date = "1900-01-01"){
  paste0("Date: ",placehold_date)
}


#' field_text
#'
#' Placeholder for text field entry parameter on the application module. 
#'
#' @param txt 
#'
#' @return
#' @export
#'
#' @examples
field_text = function(txt = "Empty"){paste0("text: ",txt)}


#' field_dropdown
#'
#' @param inputs 
#'
#' @return
#' @export
#'
#' @examples
field_dropdown = function(inputs = c()){
  type = class(inputs);paste0(type,": ",paste0(inputs,collapse=", "))
}


#' map_input
#'
#' Auxiliary function that generates instructions for the UI application. 
#'
#' @param con sqlite connection
#' @param ... all entry fields passed from generate module.
#'
#' @return
#'
#' @examples
map_input = function(con,...){
  entries = list(...)
  code_map = paste0(names(entries)," = ",entries,collapse="; ")
  return(code_map)
}



  



