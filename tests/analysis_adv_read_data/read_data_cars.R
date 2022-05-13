checkSourceContains("read.csv(","used base read function",fname="@FNAME@")
checkTrue(all(c("car","mpg","cyl","disp","hp","drat","wt","qsec","vs","am","gear","carb") %in% colnames(res)), "correct column names")
checkEquals(ncol(res),12,"correct number of features")
