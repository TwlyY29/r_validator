special_print <- function(what){
  write(what, stdout())
}

checkVariableExists <- function(var_name, what){
  n_tests_running <<- n_tests_running+1
  result <- exists(var_name, envir=sandbox)
  if(identical(result, TRUE)){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkEquals <- function(obj1, obj2, what, tolerance = .Machine$double.eps^0.5, checkNames=TRUE){
  n_tests_running <<- n_tests_running+1
  if (!identical(TRUE, checkNames)) {
    names(obj1)  <- NULL
    names(obj2) <- NULL
  }
  result <- all.equal(obj1, obj2, tolerance=tolerance)
  if(identical(result, TRUE)){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkEqualsNumeric <- function(obj1, obj2, what, tolerance = .Machine$double.eps^0.5){
  n_tests_running <<- n_tests_running+1
  result <- all.equal.numeric(as.vector(obj1), as.vector(obj2), tolerance=tolerance)
  if(identical(result, TRUE)){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkTrue <- function(expr, what){
  n_tests_running <<- n_tests_running+1
  result <- eval(expr)
  names(result) <- NULL
  
  if (identical(result, TRUE)){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkIdentical <- function(obj1, obj2, what){
  n_tests_running <<- n_tests_running+1
  result <- identical(target, current)
  if (identical(TRUE, result)) {
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkError <- function(expr, what, silent=TRUE){
  n_tests_running <<- n_tests_running+1
  if (inherits(try(eval(expr, envir=parent.frame()), silent=silent), "try-error")){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
checkSourceContains <- function(expr, what, fname=NULL, f=solution, fixed=TRUE, perl=FALSE, negate=FALSE){
  n_tests_running <<- n_tests_running+1
  if(!is.null(fname)){# check only searches body of function
    # read in the source file
    body <- paste(readLines(f),collapse='') 
    # find definition of function with opening curly bracket
    res <- regexpr(paste0(fname,"[^{]*{",collapse=''), body, perl=T)
    # remove everything up to and including the opening curly bracket
    body <- substr(body, res + attr(res, 'match.length'), nchar(body) )
    # detect end of function
    res <- regexpr('}', body)
    # and extract everything up to end of function
    body <- substr(body, 0, res-1)
  }else{# check searches complete source file
    body <- readLines(f)
  }
  x <- grep(expr, body, fixed=fixed, perl=perl)
  
  if (!identical(x, integer(0))){
    special_print(paste0(ifelse(!negate,"@OK@","@FAIL@"),what))
  }else{
    special_print(paste0(ifelse(!negate,"@FAIL@","@OK@"),what))
  }
}
