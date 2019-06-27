# Build the input requests for the basic input scheme.

# FEATURES:
#   - streamlined and flexible field inputs
#   - sqlite table construction for all available fields given specified unit of analysis
#   - {Abby} Auto-import of existing codebook. 



# Installation ------------------------------------------------------------



#' install_npm
#'
#' Install node JS to run the react library. 
#'
#' @return
#' @export
#'
#' @examples
install_npm = function(){
  os = .Platform$OS.type
  if(os == "unix"){
    version = suppressMessages(system('npm -v',ignore.stdout = T))
    if(length(version) == 0 | is.null(version)){
      cat(paste0("\nInstalling npm dependencies!",
                 "\nCode assumes user has homebrew installed on computer",
                 "\nIf this is note the case, go here (https://brew.sh/) to install homebrew."))
      system("brew install node; npm install -g serve")
      cat("\nNode JS now installed. You're good to go.")
    }else{cat("Node JS already installed. You're good to go.")}
  }else{
    version = suppressMessages(system('npm -v',ignore.stdout = T))
    if(length(version) == 0 | is.null(version)){
      cat(paste0("\nInstalling npm dependencies!",
                 "\nCode assumes user has chocolatey installed on computer",
                 "\nIf this is note the case, go here (https://chocolatey.org) to install chocolatey"))
      system("choco install nodejs; npm install -g serve")
      cat("\nNode JS now installed. You're good to go.")
    }else{cat("Node JS already installed. You're good to go.")}
  }
}



#' build_app
#'
#' Builds and moves the application to the project directory. 
#'
#' @param .project_path 
#'
#' @return
#' @export
#'
#' @examples
build_app = function(.project_path){
  
  # Build application
  system("cd user_interface; npm run build")
  
  if(fs::file_exists(file.path(.project_path,".qualify/"))){
    fs::file_delete(file.path(.project_path,".qualify/"))
  }
  
  
  # Move build to file path
  fs::dir_create(file.path(.project_path,".qualify/")) 
  fs::dir_copy("user_interface/build/",file.path(.project_path,".qualify/"))
  
  # Save thumbprint of file path
  readr::write_lines(.project_path,file.path(.project_path,".qualify","project_file_path.txt"))
  
  # Move API features over.
  fs::dir_copy("user_interface/api/",file.path(.project_path,".qualify/"))
}


#' run_app
#'
#' @param .project_path 
#'
#' @return
#' @export
#'
#' @examples
run_app = function(.project_path){
  f = file.path(.project_path,".qualify")
  system(as.character(stringr::str_glue("{f}/Rscript api/run_api.R& serve -s {f}/build")),
         intern = T, timeout = 15)
}




# Front-End Interface ----------------------------------------------

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
#' @import tidyr
#' @import dplyr
#' @import purrr
#' @import readr
#' @import stringr
#' @import RSQLite
#' @import DBI
#' @import jsonlite
#' @import plumber
#'
#' @examples
qualify = function(project_name = "test_db",
                   project_path = "~/Desktop/test_project",
                   unit_of_analysis = NULL){
  UseMethod("qualify")
}

#' @export
qualify = function(project_name = "test_db",
                   project_path = "~/Desktop/test_project",
                   unit_of_analysis = NULL){
  out = list(project_name = project_name, 
             unit_of_analysis = unit_of_analysis, 
             project_path = project_path)
  
  # Create project directory
  if(!file.exists(project_path)){dir.create(project_path)}
  
  # Save the unit of analysis as a lookup table in the SQL.
  if(!is.null(unit_of_analysis)){
    sql_instance(project_path) %>% 
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
sql_instance = function(path = "") {
  
  set_path = paste0(path,"/.qualify_data.sqlite")
  
  # Build the Data Instance.
  if(!file.exists(set_path)){
    dplyr::src_sqlite(set_path,create=T) 
    con <- dplyr::src_sqlite(set_path)
  }else{
    con <- dplyr::src_sqlite(set_path)
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
  con = sql_instance(.data$project_path)
  unit = .data$unit_of_analysis
  
  # Upload application instructions for proposed module.
  if(".input_state"  %in%  src_tbls(con)){
    current_ids = dplyr::tbl(con,".input_state") %>% dplyr::collect() %>% {.$.id}
    top_ind = max(as.numeric(gsub("v","",current_ids)))
  }else{
    top_ind = 0
  }
  
  # Write to current state of the project...
  state <- 
    tibble::tibble(var_name = variable_name,
                   caption = caption,
                   code_map = map_input(...)) %>%
    {dplyr::mutate(.,.id = paste0("v",top_ind + 1))} %>%
    dplyr::select(.,.id,dplyr::everything()) 
  DBI::dbWriteTable(con$con,name = ".input_state",value = state,append=T)
  
  
  # Generate empty table for respective variable field
  var_ind = state %>% dplyr::filter(var_name == variable_name) %>% .$.id
  names = names(list(...))
  entry = dplyr::as_tibble(matrix("",ncol = length(names)))
  colnames(entry) = names
  entry %>% 
    tidyr::crossing(tibble::tibble(.unit=unit),.) %>% 
    dplyr::mutate(timestamp = as.character(Sys.time())) %>% 
    dplyr::copy_to(dest=con,df = ., name = var_ind,overwrite = T,temporary = F)

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
  con = sql_instance(.data$project_path)
  
  # Locate specific table lookup
  var_ind <- 
    tbl(con,".input_state") %>% 
    filter(var_name==variable_name) %>% 
    collect() %>% 
    {.$.id}
  
  # Drop from the input state
  if(length(var_ind)>0){
    # If any variable entry exists for requested entry, drop table
    dplyr::copy_to(con,df=tibble::tibble(NA),name = var_ind,overwrite = T)
    
    # Drop specific data table entry
    tbl(con,".input_state") %>% 
      dplyr::collect() %>% 
      dplyr::filter(.id!=var_ind) %>% 
      dplyr::copy_to(dest=con,df = ., name = ".input_state",
                     overwrite = T,temporary = F)
  }else{
    cat(paste0("\nA module for ",variable_name," isn't present in the existing database. Entry was either deleted or has yet to be built.\n"))
  }
  
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
field_text = function(rich=F){
  if(rich){
    '<RichTextInput source= "XXXXX" label="YYYYY" />' 
  }else{
    '<TextInput source= "XXXXX" label="YYYYY" />'  
  }
}


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
  UseMethod("generate_app")
}

#' @export
generate_app = function(.data){
  app_instances <- 
    sql_instance(.data$project_path) %>% 
    dplyr::tbl(".input_state") %>% 
    dplyr::collect() 
  
  template = readr::read_lines(here::here("user_interface/src/posts_template.js"))
  
  composit = c()
  for(i in 1:nrow(app_instances)){
    tag = paste0(app_instances$.id[i],"_")
    js_code = gsub("XX_",tag,app_instances$code_map[i])
    var_name = app_instances$var_name[i]
    caption = app_instances$caption[i]
    
    composit <- 
      c(composit,
        paste0(paste0(rep("\t",7),collapse=''),'<Header header="',var_name,'" caption="',caption,'" />'),
        paste0(paste0(rep("\t",8),collapse=''),strsplit(js_code,split = "\n")[[1]]),
        paste0(paste0(rep("\t",8),collapse=''),"<Space />"))
  }
  
  
  # Compile pieces 
  c(template[1:grep("XXXXX",template)-1],
    composit,
    template[grep("XXXXX",template)+1:length(template)]) %>% 
    {.[!is.na(.)]} %>% 
    readr::write_lines(.,here::here("user_interface/src/posts_compiled.js"))
    
  cat("\nApp generated!\n")
}




# API Function Calls ------------------------------------------------------

#' import_data_state
#'
#' [AUX.] Function reads in and reports on the state of the established coding
#' task
#'
#' @param .project_name initial name of the data_base build.
#'
#' @return exports all units along with the current state of the projec
import_data_state <- function(.project_path = "",empty_value_placeholder=""){
  con = sql_instance(.project_path) 
  all_tbls = grep("v", dplyr::src_tbls(con),value = T)
  report = c()
  ts_tracker = c()
  for ( t in all_tbls){
    
    # Draw out the most recent entry from the data folder
    tmp <-
      dplyr::tbl(con,t) %>% 
      dplyr::collect() %>% 
      dplyr::group_by(.unit) %>% 
      dplyr::arrange(desc(timestamp)) %>% 
      dplyr::slice(1) %>% 
      dplyr::ungroup()
    
    # Build timestamp tracker
    ts_tracker <- dplyr::bind_rows(ts_tracker,dplyr::transmute(tmp,id = .unit,timestamp))
    
    #Generate report 
    report <- 
      tmp %>% 
      dplyr::select(-timestamp) %>% 
      dplyr::bind_rows(report,.) 
  }
  
  # return the data state with a progress report
  current_state <-
    report %>% 
    dplyr::group_by(.unit) %>% 
    tidyr::nest() %>% 
    dplyr::mutate(progress = map(data,function(x) sum(rowSums(x == empty_value_placeholder | is.na(x)) < ncol(x))/nrow(x))) %>% 
    tidyr::unnest(progress) %>% 
    dplyr::select(id = .unit, Progress = progress)
  
  # Map on last updated and return data
  ts_tracker %>% 
    dplyr::group_by(id) %>% 
    dplyr::arrange(timestamp) %>% 
    dplyr::slice(1) %>% 
    dplyr::rename(`Last Update` = timestamp) %>% 
    dplyr::left_join(current_state,.,by = "id")
}


#' api_data_call
#'
#' [AUX.] Wrapper that calls to the current state of the coding task to feed to
#' the API upon a GET from the UI client.
#'
#' @param unit
#' @param .project_name
#'
#' @return
api_data_call = function(unit = "",.project_path = ""){
  con = sql_instance(.project_path)
  all_tbls = grep("v",dplyr::src_tbls(con),value = T)
  api_order <- c()
  for(t in all_tbls){
    dplyr::tbl(con,t) %>%
      dplyr::filter(.unit == unit) %>%
      dplyr::arrange(desc(timestamp)) %>% 
      dplyr::select(-.unit) %>% 
      dplyr::collect() %>% 
      dplyr::slice(1) %>% 
      dplyr::select(-timestamp) %>% 
      {colnames(.) = paste0(t,"_",colnames(.));.} %>% 
      dplyr::bind_cols(api_order,.) -> api_order
  }
  api_order$id = unit
  return(as.data.frame(api_order)) # Send back the request
}


#' upload_data
#'
#' [AUX.] Wrapper that saves user input to the existing database structure after
#' receiving a post request from the client. 
#'
#' @param entry
#' @param .project_name
#'
#' @return
upload_data = function(entry,.project_path = ""){
  # Process entry records for resubmission into the data element. 
  id = entry$id 
  entry["id"] = NULL
  entry["Progress"] = NULL
  entry["Last Update"] = NULL
  tags = stringr::str_remove_all(stringr::str_extract_all(names(entry),"v\\d_",simplify = T),"_") 
  vars = stringr::str_remove_all(names(entry),"v\\d_")
  entries = unlist(entry,use.names = F)
  
  # Loop through tags and draw out relevant features
  for(t in unique(tags)){
    tmp = 
      tibble::tibble(.tag = t,vars = vars[tags == t],entry = entries[tags == t]) %>% 
      tidyr::spread(vars,entry,fill="") %>% 
      dplyr::mutate(.unit=id) %>% 
      dplyr::mutate(timestamp = as.character(Sys.time())) %>% 
      dplyr::select(-.tag)
      
    # Append to existing data frame
    con = sql_instance(.project_path)
    DBI::dbWriteTable(conn=con$con, name = t, value = tmp,append=T) 
  }
}


# Posterior Functions --------------------------------------------------

# Pull data out of the data base. 
# (Only optimized for a single coder at the moment)


#' pull_timeline
#' 
#' Pull in timeline information about the coding timeline.
#'
#' @param .project_path 
#'
#' @return
#' @export
#'
#' @examples
pull_timeline = function(.project_path,round_date = "minute"){
  if(dir.exists(.project_path) & check_db_exists(.project_path)){
    con = sql_instance(.project_path) 
    all_tbls = grep("v", dplyr::src_tbls(con),value = T)
    data_summary = c()
    
    for (t in all_tbls){
      # Get the variable name
      var_name =  dplyr::tbl(con,".input_state") %>% 
        dplyr::filter(.id == t) %>% 
        dplyr::collect() %>% .$var_name
      
      # Extract the data state
      data_summary <-
        dplyr::tbl(con,t) %>% 
        dplyr::collect() %>% 
        dplyr::mutate(timestamp = lubridate::round_date(lubridate::ymd_hms(timestamp),unit = round_date),
                      variable = var_name) %>% 
        dplyr::group_by(timestamp,.unit,variable) %>% 
        tidyr::nest() %>% 
        dplyr::mutate(is_entry = purrr::map(data,function(x) (apply(x,1,function(x) as.numeric(sum(x=="") < length(x)))) )) %>%
        tidyr::unnest() %>% 
        dplyr::filter(is_entry==1) %>% 
        dplyr::group_by(timestamp,variable) %>% 
        dplyr::count() %>% 
        dplyr::ungroup() %>% 
        dplyr::bind_rows(data_summary,.)
    }
    return(data_summary)
  } else{
    cat("\nNo qualify database located in the provide path.\n")
  }
} 


#' pull_data
#'
#' Posterior function that call from the data base to make a distinct data frame
#' that contains all fields from all coded variables from the application. The
#' function allows users to draw the most recent state of the coding task to
#' convert into a usable data frame for analysis
#'
#' @param .project_path
#'
#' @return
#' @export
#'
#' @examples
#'
#' # Must point to the project path created by qualify()
#' pull_data(.project_path = "~/Desktop/test_project/")
#' 
pull_data = function(.project_path = ""){
  if(dir.exists(.project_path) & check_db_exists(.project_path)){
    con = sql_instance(.project_path) 
    all_tbls = grep("v", dplyr::src_tbls(con),value = T)
    data_summary = c()
    
    for (t in all_tbls){
      # Get the variable name
      var_name =  dplyr::tbl(con,".input_state") %>% 
        dplyr::filter(.id == t) %>% 
        dplyr::collect() %>% .$var_name
      
      # Extract the data state
      data_summary <-
        dplyr::tbl(con,t) %>% 
        dplyr::collect() %>% 
        dplyr::group_by(.unit) %>% 
        dplyr::arrange(desc(timestamp)) %>% 
        dplyr::slice(1) %>% 
        dplyr::ungroup() %>% 
        dplyr::mutate(variable = var_name) %>% 
        select(variable,.unit,timestamp,dplyr::everything()) %>% 
        dplyr::bind_rows(data_summary,.) 
    }
    return(data_summary)
  } else{
    cat("\nNo qualify database located in the provide path.\n")
  }
  
} 


#' check_db_exists
#' 
#' [Aux.] Check if a data base file exist
#'
#' @param path 
#'
#' @return
#'
#' @examples
#' 
#' check_db_exists()
#' 
check_db_exists = function(.project_path = ""){
  set_path = paste0(path,"/.qualify_data.sqlite")
  file.exists(set_path)
}

