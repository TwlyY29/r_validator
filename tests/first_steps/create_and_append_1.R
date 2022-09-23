checkSourceContains("c(","used base c function")
checkVariableExists("result", "variable 'result' exists")
checkEqualsNumeric(length(result), 16, "correct length of vector")
checkEqualsNumeric(result,c(13,16,19,22,25,28,5,7,9,11,13,15,17,19,21,23), "correctly combined vector")
