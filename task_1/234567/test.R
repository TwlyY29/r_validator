n_cases <- 9
test_cases <- c(
  "test.create_sequence_from_10_to_20","test.create_sequence_from_20_to_30","test.create_sequence_from_40_to_80","test.sum_4th_and_6th_position","test.sum_vec1_and_vec2_without_plus","test.plot_pie_chart","test.plot_barplot_to_png","test.read_data_iris","test.plot_data"
)
cases_function_names <- c(
  "create_sequence_from_10_to_20","create_sequence_from_20_to_30","create_sequence_from_40_to_80","sum_4th_and_6th_position","sum_vec1_and_vec2_without_plus","plot_pie_chart","plot_barplot_to_png","read_data_iris","plot_data"
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
# expect solution file as command line argument
solution_raw <- commandArgs(trailingOnly=TRUE)[1]
solution <- gsub('.R$','.exec.R',solution_raw)

# we have added dummy execution of functions to help students test their functions
# when sourcing the solution, these functions mustn't be executed because they
# might produce Rplots.pdf - so we have no possibility to make sure that file
# is created during testing
tmp <- readLines(solution_raw)
sapply(cases_function_names, function(fun){
  pattern = paste0('^',fun,'\\(')
  tmp <<- gsub(pattern = pattern, replace=paste0('#',fun,'('), x = tmp, fixed = F)
})
writeLines(tmp, solution)

# set up a sandboxed environment
sandbox <- new.env(parent=.GlobalEnv)

# try to source student solution catching syntax errors
res <- try(sys.source(solution, envir=sandbox), silent=T)
if (inherits(res, "try-error")) {
  special_print("@ERROR@Error while loading your solution. Did you run your script successfully on your computer?")
}else{
  # add required test functions to sandbox environment
  sandbox$test.create_sequence_from_10_to_20 <- function(){
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- create_sequence_from_10_to_20()
    sink()
    checkEquals(length(res), 11, "length of list")
    checkTrue(res[2]-res[1] == 1, "step size")
    checkEqualsNumeric(res, 10:20, "values")
  }
  environment(sandbox$test.create_sequence_from_10_to_20) <- sandbox

  sandbox$test.create_sequence_from_20_to_30 <- function(){
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- create_sequence_from_20_to_30()
    sink()
    checkEquals(length(res), 11, "length of list")
    checkTrue(res[2]-res[1] == 1, "step size")
    checkEqualsNumeric(res, 20:30, "values")
  }
  environment(sandbox$test.create_sequence_from_20_to_30) <- sandbox

  sandbox$test.create_sequence_from_40_to_80 <- function(){
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- create_sequence_from_40_to_80()
    sink()
    checkTrue(res[2]-res[1] == 2, "step size")
    checkEqualsNumeric(res, seq(40,80,2), "values")
    checkSourceContains("seq(", "use seq function", fixed=T)
  }
  environment(sandbox$test.create_sequence_from_40_to_80) <- sandbox

  sandbox$test.sum_4th_and_6th_position <- function(){
    vec <- c(10:20)
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- sum_4th_and_6th_position(vec)
    sink()
    checkEquals(res,28,"value") # 13+15
    vec <- c(20:40)
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- sum_4th_and_6th_position(vec)
    sink()
    checkEquals(res,48, "value") # 23+25
  }
  environment(sandbox$test.sum_4th_and_6th_position) <- sandbox

  sandbox$test.sum_vec1_and_vec2_without_plus <- function(){
    checkSourceContains("+","not used +",fname="sum_vec1_and_vec2_without_plus", fixed=T,negate=T) 
    vec1 <- c(10:20)
    vec2 <- c(20:30)
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- sum_vec1_and_vec2_without_plus(vec1,vec2)
    sink()
    checkEqualsNumeric(res,440,"standard values") 
    vec1 <- c(20:40)
    vec2 <- c(20:40)
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- sum_vec1_and_vec2_without_plus(vec1,vec2)
    sink()
    checkEqualsNumeric(res,1260, "new values") 
  }
  environment(sandbox$test.sum_vec1_and_vec2_without_plus) <- sandbox

  sandbox$test.plot_pie_chart <- function(){
    checkSourceContains("pie(","used base pie function",fname="plot_pie_chart")
    checkSourceContains("main *=","assigned a title",fname="plot_pie_chart", fixed=F) 
    checkSourceContains("labels *=","assigned labels",fname="plot_pie_chart", fixed=F)
    files_before <- list.files(path=".")
    data <- c(10,15,25,30,10,10)
    labels <- LETTERS[1:6]
    main <- "bla, fasel"
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- plot_pie_chart(data, labels, main)
    sink()
    files_after <- list.files(path=".")
    new_files <- setdiff(files_after, files_before)
    file.remove(new_files)
    checkTrue("Rplots.pdf" %in% new_files, "Plot created (inside Rplots.pdf)")
  }
  environment(sandbox$test.plot_pie_chart) <- sandbox

  sandbox$test.plot_barplot_to_png <- function(){
    checkSourceContains("barplot(","used base barplot function",fname="plot_barplot_to_png")
    checkSourceContains("main *=","assigned a title",fname="plot_barplot_to_png", fixed=F) 
    checkSourceContains("names.arg *=","assigned labels",fname="plot_barplot_to_png", fixed=F)
    files_before <- list.files(path=".")
    data <- c(10,15,25,30,10,10)
    labels <- LETTERS[1:6]
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- plot_barplot_to_png(data, labels)
    sink()
    files_after <- list.files(path=".")
    new_files <- setdiff(files_after, files_before)
    file.remove(new_files)
    checkTrue("test.png" %in% new_files, "Plot saved to test.png")
  }
  environment(sandbox$test.plot_barplot_to_png) <- sandbox

  sandbox$test.read_data_iris <- function(){
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- read_data_iris()
    sink()
    checkSourceContains("read.csv(","used base read function",fname="read_data_iris")
    checkTrue(all(c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width","Species") %in% colnames(res)), "correct column names")
    checkTrue(is.factor(res$Species), "strings are factors")
  }
  environment(sandbox$test.read_data_iris) <- sandbox

  sandbox$test.plot_data <- function(){
    checkSourceContains("plot(","used base plot function",fname="plot_data")
    checkSourceContains("main *=","assigned a title",fname="plot_data", fixed=F) 
    checkSourceContains("col *=","used colors",fname="plot_data", fixed=F)
    checkSourceContains("col *=[^\\$]*\\$(Species|cyl|vs|am|gear|carb)","used an appropriate feature as colors",fname="plot_data", fixed=F, perl=T)
    files_before <- list.files(path=".")
    sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
      res <- plot_data()
    sink()
    files_after <- list.files(path=".")
    new_files <- setdiff(files_after, files_before)
    file.remove(new_files)
    checkTrue("Rplots.pdf" %in% new_files, "Plot created (inside Rplots.pdf)")
  }
  environment(sandbox$test.plot_data) <- sandbox


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
file.remove(solution)

