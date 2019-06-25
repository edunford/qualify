# Run Test code
require(tidyverse)

# Source in file information. 
source(here::here("R/qualify.R"))

# Manual build of the data entries
qualify(project_name = "test_db",
        unit_of_analysis = c("aa","bb","c3","d")) %>%

  generate_module(variable_name = "var_1",
                  caption = "This variable is about this ...",
                  evidence = field_text(),
                  note = field_text(),
                  publication_date = field_date(),
                  division_1 = field_dropdown(c(1,2,3,4))) %>%

  generate_module(variable_name = "var_2",
                  caption = "This variable is about something else ...",
                  notes = text_field())



# Looking into the database...
qualify() %>%
  {sql_instance(.$project_name)} %>%
  tbl(".input_state") %>%
  collect() 

qualify() %>%
  {sql_instance(.$project_name)} %>%
  tbl("field_var_1") %>%
  collect()


# Dropping any existing data structure
qualify() %>% drop_module("var_1") %>% drop_module("var_2")







# (TEMP) Application Functionality -------------------------------------------------------------

plmb_data_call = function(unit = "",.project_name = "test_db"){
  con = sql_instance(.project_name) 
  all_tbls = grep("field_",src_tbls(con),value = T)
  api_order = as.list(rep(NA,length(all_tbls)))
  names(api_order) = all_tbls
  for(t in all_tbls){
    api_order[[t]] = 
      tbl(con,t) %>% 
      filter(.unit == unit) %>% 
      collect()
  }
  return(api_order) # Send back the request
}


