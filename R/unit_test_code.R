# Run Test code
require(tidyverse)

source(here::here("R/qualify.R"))

# Manual build of the data entries
qualify(project_name = "test_db",
        unit_of_analysis = c("a","b","c","d")) %>%

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
  collect() %>% View()

qualify() %>%
  {sql_instance(.$project_name)} %>%
  tbl("var_1") %>%
  collect()


# Dropping any existing data structure
qualify() %>% drop_module("var_1") %>% drop_module("var_2")
