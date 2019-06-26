


#what do you want #database, document, paragraph, sentence, 
# display first 6 of that
# coding framework

#define UNIT -> get variable names from UNIT" ->structure that Shiny can read

#things that should be stored as nested list items: class (document, paragraph, etc.), variables names

#names/codes read in by somewhere else, check for duplicates
#export data object piped to next feature
#specify class as method->breaks if method is not good

#read code options 

define_unit<-function(){ #var names from drop down menu
  bigLL <- list()
  num_docs<-3
  for( i in 1:num_docs ){
    
    ll <- list( unit1 = i , unit2 = letters[i])
    bigLL[[i]] <- ll
    

  
  # Function generates a shell of the input data structure
  
  variables <- 
  complete_vars = list(general_notes="",group_history_notes="",data_availability="")
  for(v in variables){
    complete_vars = c(complete_vars,gen_data_structure(v))
  }
  complete = c()
  for(g in groups){
    complete = c(complete,list(x=complete_vars))
  }
  names(complete) = groups
  return(complete)
}
} 