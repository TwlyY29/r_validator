sink(file=ifelse(.Platform$OS.type == "unix", "/dev/null", "nul"))
  res <- @FUN_CALL@
sink()
