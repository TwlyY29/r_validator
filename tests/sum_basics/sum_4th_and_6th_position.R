vec <- c(10:20)
@CALL@
checkEquals(res,28,"value") # 13+15
vec <- c(20:40)
@CALL@
checkEquals(res,48, "value") # 23+25
