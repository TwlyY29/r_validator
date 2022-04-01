checkSourceContains("+","not used +",fname="@FNAME@", fixed=T,negate=T) 
@STD_PARAMS@
@CALL@
checkEqualsNumeric(res,440,"standard values") 
vec1 <- c(20:40)
vec2 <- c(20:40)
@CALL@
checkEqualsNumeric(res,1260, "new values") 
