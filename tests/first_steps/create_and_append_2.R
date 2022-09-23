checkSourceContains("c(","used base c function")
checkVariableExists("result", "variable 'result' exists")
checkEqualsNumeric(length(result), 12, "length of vector")
checkEqualsNumeric(result, c(10,12,14,16,18,23,20,17,14,11,8,5), "combined vector")
