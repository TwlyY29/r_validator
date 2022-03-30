n_cases <- ###NUM_TESTCASES###
test_cases <- c(
  "###ADD_TEST_FUNCTIONS_HERE###"
)
cases_function_names <- c(
  "###ADD_R_FUNCTIONS_HERE###"
)
n_tests_running <- 0

special_print <- function(what){
  write(what, stdout())
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
checkSourceContains <- function(expr, what, f=solution, fixed=TRUE){
  n_tests_running <<- n_tests_running+1
  x <- grep(expr, readLines(f), fixed=fixed)
  if (!identical(x, integer(0))){
    special_print(paste0("@OK@",what))
  }else{
    special_print(paste0("@FAIL@",what))
  }
}
# expect solution file as command line argument
solution <- commandArgs(trailingOnly=TRUE)[1]

# set up a sandboxed environment
sandbox <- new.env(parent=.GlobalEnv)

# try to source student solution catching syntax errors 
res <- try(sys.source(solution, envir=sandbox), silent=T)
if (inherits(res, "try-error")) {
  special_print("@ERROR@Error while loading your solution")
}else{
  # add required test functions to sandbox environment
###ADD_SOURCES_HERE###
  sandbox$special_print <- function(what){
    write(what, stdout())
  }
  environment(sandbox$special_print) <- sandbox
  
  void <- sapply(1:n_cases, function(i){
    n_tests_running <<- 0
    special_print(paste0("@START@",cases_function_names[i]))
    
    # get test function and move it to sandbox environment
    func <- get(test_cases[i], envir=sandbox)
    
    # execute function omitting all the output from the student's script
    res <- try(func())
    
    special_print(paste0("@NTESTS@",n_tests_running))
  })
  special_print("@END@")
}
