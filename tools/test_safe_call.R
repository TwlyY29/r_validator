@FUN_TEST@ <- function(){
  sink(file="/dev/null")
    res <- @FUN_CALL@
  sink()
  @TESTS@
}
