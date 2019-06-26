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
#' @param project_path 
#'
#' @return
#' @export
#'
#' @examples
qualify = function(project_name = "test_db",
                   project_path = "",
                   unit_of_analysis = NULL){
  UseMethod("qualify")
}

#' @export
qualify = function(project_name = "test_db",
                   project_path = "",
                   unit_of_analysis = NULL){
  out = list(project_name = project_name, unit_of_analysis = unit_of_analysis)
  
  # Establish path...
  
  # Save the unit of analysis as a lookup table in the SQL.
  if(!is.null(unit_of_analysis)){
    sql_instance(project_name) %>% 
      dplyr::copy_to(dest = .,
                     df=tibble(id=unit_of_analysis),
                     name=".unit",overwrite=T,temporary=F) 
  }
  
  # Establish qualify class
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
  if(!file.exists(here::here(paste0("Data/",db_name,".sqlite")))){
    dplyr::src_sqlite(here::here(paste0("Data/",db_name,".sqlite")),create=T) 
    con <- dplyr::src_sqlite(here::here(paste0("Data/",db_name,".sqlite")))
  }else{
    con <- dplyr::src_sqlite(here::here(paste0("Data/",db_name,".sqlite")))
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
  entry = dplyr::as_tibble(matrix(-99,ncol = length(names)))
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
field_date = function(){'<DateInput source= "XXXXX" label="YYYYY" />'}


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
field_text = function(){'<TextInput source= "XXXXX" label="YYYYY" />'}


#' field_dropdown
#'
#' @param inputs 
#'
#' @return
#' @export
#'
#' @examples
field_dropdown = function(inputs = c()){
  paste0('<SelectInput source= "XXXXX" label="YYYYY" choices={[',paste0("{ id: '",inputs,"', name: '",inputs,"'}",collapse = ","),"]} />")
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
  entry_names = names(entries)
  code_map = c()
  for(i in seq_along(entries)){
    code_map = c(code_map,populate_source(entry_names[i],entries[[i]]))
  }
  code_map = paste0(code_map,collapse="\n")
  return(code_map)
}


#' populate_source
#' 
#' [Aux] populate internal source code for js argument. 
#'
#' @param source_name 
#' @param expr 
#'
#' @return js code snippet with the appropriate source name
#'
#' @examples
populate_source = function(source_name="",expr){
  expr = gsub("YYYYY",source_name,expr)
  gsub("XXXXX",paste0("XX_",source_name),expr)
}

  


#' generate_app
#' 
#' Function compiles the JS code. 
#'
#' @param .data 
#'
#' @return
#' @importFrom magrittr "%>%"
#' @export
#'
#' @examples
generate_app = function(.data){
  app_instances <- 
    sql_instance(.data$project_name) %>% 
    tbl(".input_state") %>% 
    collect() 
  
  template = readr::read_lines(here::here("user_interface/src/posts_template.js"))
  
  composit = c()
  for(i in 1:nrow(app_instances)){
    tag = paste0(app_instances$.id[i],"_")
    js_code = gsub("XX_",tag,app_instances$code_map[i])
    var_name = app_instances$var_name[i]
    caption = app_instances$caption[i]
    
    composit <- 
      c(composit,
        paste0(paste0(rep("\t",7),collapse=''),'<Header variable="',var_name,'" />'),
        paste0(paste0(rep("\t",7),collapse=''),'<Caption variable="',caption,'" />'),
        paste0(paste0(rep("\t",8),collapse=''),strsplit(js_code,split = "\n")[[1]]))
  }
  
  
  # Compile pieces 
  c(template[1:grep("XXXXX",template)-1],
    composit,
    template[grep("XXXXX",template)+1:length(template)]) %>% 
    {.[!is.na(.)]} %>% 
    readr::write_lines(.,here::here("user_interface/src/posts_compiled.js"))
    
  cat("\nApp generated!\n")
}




