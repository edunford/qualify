##### PARSE CODEBOOK ###### 

file_example<-'PUMSDataDict13.txt'
file_example<-'commoncore.txt'

library(stringr)


parse.codebook <- function(file, 
                           var.names=c("var", "desc"), 
                           level.names=c("level", "label"),
                           level.indent=c(' ','\t'),
                           var.sep, 
                           level.sep, 
                           var.widths,
                           level.widths,
                           var.name = 'var',
                           skip=0,
                           ...) {
 
  
  codebook.raw <- readLines(file_example, warn=FALSE)[-c(0:skip)]
  
  
  #Remove blank lines
  blanklines <- which(nchar(str_squish(codebook.raw)) == 0)
  linenums <- which(!(substr(codebook.raw, 1, 1) %in% level.indent))
  linenums <- linenums[!linenums %in% blanklines] #from raw codebook 
  linenums.levels <- which(substr(codebook.raw, 1, 1) %in% level.indent)
  linenums.levels <- linenums.levels[!linenums.levels %in% blanklines]
  
  if(length(blanklines) > 0) {
    codebook.raw <- codebook.raw[-blanklines]		
  }
  

  
  rows <- which(!(substr(codebook.raw, 1, 1) %in% level.indent))
  rows.levels <- which(substr(codebook.raw, 1, 1) %in% level.indent)
  rowmapping <- data.frame(pre=linenums, post=rows) #linenums are from raw codebook
  rowmapping.levels <- data.frame(pre=linenums.levels, post=rows.levels)
  codebook <- str_squish(codebook.raw[rows])
  
  if(!missing(var.sep)) { #Fields are delimited
    split <- strsplit(codebook, var.sep, fixed=TRUE)
    split<-lapply(split, function(x) x[!x %in% ""])
    codebook <- codebook[lapply(split, length) == length(var.names)] #no more bad rows!!!!
  
    
    codebook <- as.data.frame(matrix(sapply(str_squish(codebook), function(x) trimws(x, "right"))), #, fixed=TRUE
      ncol=length(var.names), byrow=TRUE, stringsAsFactors=FALSE)
    codebook$linenum <- rows
    

  } else if(!missing(var.widths)) { #Fields are fixed width
    stopifnot(length(var.names) == length(var.widths))
    left_side_of_string <- 1
    
    codebook.new <- data.frame(linenum=linenums)

    for(i in 1:length(var.widths)) {
      codebook.new[,var.names[i]] <- sapply(
        codebook, function(x) {
          str_squish(substr(x, start=left_side_of_string, stop = min(nchar(x), (left_side_of_string + var.widths[i]))))
        })
      left_side_of_string <- left_side_of_string + var.widths[i]
    }
    
    codebook <- codebook.new
    
  } else {
    stop("Must specify either var.sep or var.widths")
  }
  
  
  varsWithFactors <- which(sapply(1:(length(rows)-1), 
                                  FUN=function(x) { rows[x] + 1 != rows[x+1] }))
  
  
  varlevels <- list()
  for(i in 1:length(rows[varsWithFactors])) {
    start <- rows[varsWithFactors][i]
    end <- rows[which(rows == start) + 1]
    levels.raw <- codebook.raw[ (start + 1):(end - 1) ]
    if(!missing(level.widths)) { #Fixed width levels
      levels.raw <- lapply(levels.raw, FUN=function(x) {
        left_side_of_string <- 1
        levels<-c()
        for(i in 1:length(level.widths)) {
          levels<- c(levels, 
                  substr(x, left_side_of_string, min(nchar(x), (left_side_of_string + level.widths[[i]])))
          )
          left_side_of_string <- left_side_of_string + level.widths[i]
        }
        return(levels)
      })
      
    } else if(exists("level.sep")) { #Delimited levels
      levels.raw <- str_squish(levels.raw) 
    } else {
      stop('Specify  either level.sep or level.widths')
    }
    
    
    levels.df <- data.frame(linenum=rowmapping.levels[rowmapping.levels$post > start &
                                                        rowmapping.levels$post < end, 'pre'])
    for(i in 1:length(level.names)) {
      levels.df[,level.names[i]] <- sapply(levels.raw, FUN=function(x) { str_squish(x[i]) })
    }

    var <- codebook[codebook$linenum == rowmapping[start == rowmapping$post,'pre'], "var"]
    varlevels[[var]] <- levels.df
  }

  codebook$isfactor <- codebook$var%in% names(varlevels)
  
  attr(codebook, 'levels') <- varlevels
  class(codebook) <- c('codebook', 'data.frame')
  return(codebook)
}

