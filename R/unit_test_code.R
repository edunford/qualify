# Run Test code
require(tidyverse)

# Source in file information. 
source(here::here("R/qualify.R"))

# Manual build of the data entries
qualify(project_name = "test_db",
        unit_of_analysis = c("aa","bb","c3","d")) %>%

  generate_module(variable_name = "var_1",
                  caption = "...",
                  evidence = field_text(),
                  publication_date = field_date(),
                  code = field_dropdown(c(1,2,3,4))) %>% 
  
  generate_module(variable_name = "var_2",
                  caption = "...",
                  evidence = field_text(),
                  publication_date = field_date(),
                  code = field_dropdown(c(1,2,3,4))) %>% 
  
  generate_app()



# Looking into the database...
qualify() %>%
  {sql_instance(.$project_name)} %>%
  tbl(".input_state") %>%
  collect()

qualify() %>%
  {sql_instance(.$project_name)} %>% 
  tbl(".unit")

qualify() %>%
  {sql_instance(.$project_name)} %>%
  tbl("field_var_1") %>%
  collect()


# Dropping any existing data structure
qualify() %>% drop_module("var_1") %>% drop_module("var_2")




