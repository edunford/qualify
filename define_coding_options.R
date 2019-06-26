#' Parsing an inported codebook 
#' 
#' Parsing a codebook that  contains variable information (e.g. name, description, type) and indented lines 
#' (i.e. lines beginning with white space, either tabs or spaces, etc.) represent factor
#' levels and labels. 
#' 
#' @param file codebook file name (should be in .txt format)
#' @param var_names the names of the columns with the fields as rows
#' @param level_names the names of levels within each field
#' @param level_indent the character that separates levels and the labels
#' @param var_sep the separator for the fields
#' @param level_sep the separator for the levels
#' @param var_widths for fixed width fields
#' @param level_widths for fixed width levels
#' @param var_name the column name that contains all of the fields
#' @param skip the number of lines to skip when reading in the .txt file
#' @param ... 
#'
#' @return the codebook as a data frame with \code{levels} as an attribute. \code{levels} contains a list for each field that has its levels in a data frame
#' @export
#'
#' @examples
parse_codebook <- function(file, 
                           var_names=c("var", "desc"), 
                           level_names=c("level", "label"),
                           level_indent=c(' ','\t'),
                           var_sep, 
                           level_sep, 
                           var_widths,
                           level_widths,
                           var_name = 'var',
                           skip=0,
                           ...) {
 
  
  codebook_raw <- readLines(file_example, warn=FALSE)[-c(0:skip)]
  
  
  #Remove blank lines
  blank_lines <- which(nchar(stringr::str_squish(codebook_raw)) == 0)
  linenums <- which(!(substr(codebook_raw, 1, 1) %in% level_indent))
  linenums <- linenums[!linenums %in% blank_lines] #from raw codebook 
  linenums.levels <- which(substr(codebook_raw, 1, 1) %in% level_indent)
  linenums.levels <- linenums.levels[!linenums.levels %in% blank_lines]
  
  if(length(blank_lines) > 0) {
    codebook_raw <- codebook_raw[-blank_lines]		
  }
  

  
  rows <- which(!(substr(codebook_raw, 1, 1) %in% level_indent))
  rows.levels <- which(substr(codebook_raw, 1, 1) %in% level_indent)
  rowmapping <- data.frame(pre=linenums, post=rows) #linenums are from raw codebook
  rowmapping.levels <- data.frame(pre=linenums.levels, post=rows.levels)
  codebook <- stringr::str_squish(codebook_raw[rows])
  
  if(!missing(var_sep)) { #Fields are delimited
    split <- strsplit(codebook, var_sep, fixed=TRUE)
    split<-lapply(split, function(x) x[!x %in% ""])
    codebook <- codebook[lapply(split, length) == length(var_names)] #no more bad rows!!!!
  
    
    codebook <- as.data.frame(matrix(sapply(stringr::str_squish(codebook))
      ncol=length(var_names), byrow=TRUE, stringsAsFactors=FALSE)
    codebook$linenum <- rows
    

  } else if(!missing(var_widths)) { #Fields are fixed width
    stopifnot(length(var_names) == length(var_widths))
    left_side_of_string <- 1
    
    codebook.new <- data.frame(linenum=linenums)

    for(i in 1:length(var_widths)) {
      codebook.new[,var_names[i]] <- sapply(
        codebook, function(x) {
          stringr::str_squish(substr(x, start=left_side_of_string, stop = min(nchar(x), (left_side_of_string + var_widths[i]))))
        })
      left_side_of_string <- left_side_of_string + var_widths[i]
    }
    
    codebook <- codebook.new
    
  } else {
    stop("Must specify either var_sep or var_widths")
  }
  
  
  varsWithFactors <- which(sapply(1:(length(rows)-1), 
                                  FUN=function(x) { rows[x] + 1 != rows[x+1] }))
  
  
  varlevels <- list()
  for(i in 1:length(rows[varsWithFactors])) {
    start <- rows[varsWithFactors][i]
    end <- rows[which(rows == start) + 1]
    levels.raw <- codebook_raw[ (start + 1):(end - 1) ]
    if(!missing(level_widths)) { #Fixed width levels
      levels.raw <- lapply(levels.raw, FUN=function(x) {
        left_side_of_string <- 1
        levels<-c()
        for(i in 1:length(level_widths)) {
          levels<- c(levels, 
                  substr(x, left_side_of_string, min(nchar(x), (left_side_of_string + level_widths[[i]])))
          )
          left_side_of_string <- left_side_of_string + level_widths[i]
        }
        return(levels)
      })
      
    } else if(exists("level_sep")) { #Delimited levels
      levels.raw <- stringr::str_squish(levels.raw) 
    } else {
      stop('Specify  either level_sep or level_widths')
    }
    
    
    levels.df <- data.frame(linenum=rowmapping.levels[rowmapping.levels$post > start &
                                                        rowmapping.levels$post < end, 'pre'])
    for(i in 1:length(level_names)) {
      levels.df[,level_names[i]] <- sapply(levels.raw, FUN=function(x) { stringr::stringr::str_squish(x[i]) })
    }

    var <- codebook[codebook$linenum == rowmapping[start == rowmapping$post,'pre'], "var"]
    varlevels[[var]] <- levels.df
  }

  codebook$isfactor <- codebook$var%in% names(varlevels)
  
  attr(codebook, 'levels') <- varlevels
  class(codebook) <- c('codebook', 'data.frame')
  return(codebook)
}

