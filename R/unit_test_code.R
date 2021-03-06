# Run Test code
require(tidyverse)

# Source in file information. 
source(here::here("R/qualify.R"))

# Manual build of the data entries
qualify(project_name = "test_db",
        project_path = "~/Desktop/test_project",
        unit_of_analysis = c("aa","bb","c3","d")) %>%

  generate_module(variable_name = "var_1",
                  caption = "This is something",
                  evidence = field_text(rich=T),
                  publication_date = field_date(),
                  code = field_dropdown(c(1,2,3,4))) %>% 
  
  generate_module(variable_name = "variable_2",
                  caption = "Another variable",
                  evid = field_text(),
                  date = field_date(),
                  code = field_dropdown(c(1,2,3,4))) %>% 
  
  generate_module(variable_name = "Violent Deaths",
                  caption = "Another variable",
                  count = field_dropdown(c("0-100","100-500","500 +")),
                  date = field_date()) %>% 
  
  generate_app()


# Dropping any existing data structure
qualify() %>% 
  drop_module("var_1") %>% 
  drop_module("variable_2") %>% 
  drop_module("Violent Deaths") 


# Looking into the database...
qualify() %>%
  {sql_instance(.$project_path)} %>%
  tbl(".input_state") %>%
  collect()

qualify() %>%
  {sql_instance(.$project_path)} %>% 
  tbl(".unit")

qualify() %>%
  {sql_instance(.$project_path)} %>%
  tbl("v1") %>%
  collect()


# Posterior functions -----------------------------------------------------

# Pull timeline of data entries 
pull_timeline("~/Desktop/test_project/",round_date = "second")

    # Various time dates work
    pull_timeline("~/Desktop/test_project/",round_date = "minute")
    pull_timeline("~/Desktop/test_project/",round_date = "month")
    
    # Curation example: plotting contributions
    pull_timeline("~/Desktop/test_project/",round_date = "hour") %>% 
      ggplot(aes(timestamp,n,fill=variable)) +
      geom_col(position = "dodge") 
    

# Pull workable data frame from existing project
pull_data("~/Desktop/test_project/") 

    # Curation example: converting output into a usable data object. 
    pull_data("~/Desktop/test_project/") %>% 
      select(country = .unit, variable,code) %>% 
      mutate(code = as.numeric(code)) %>% 
      spread(variable,code,fill = 0) 


    # Example data for R & K
    bind_rows(
      pull_data("~/Desktop/test_project/") %>% 
        mutate(.user = "eric") %>% 
        select(.user,everything()),
      pull_data("~/Desktop/test_project/") %>% 
        mutate(.user = "Rebecca") %>% 
        select(.user,everything())
    ) %>% 
      write_csv(.,"Data/example_pull_data_w_2users.csv")
    
    

