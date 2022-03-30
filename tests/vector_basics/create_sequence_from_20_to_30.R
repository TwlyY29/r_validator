checkEquals(length(res), 11, "length of list")
checkTrue(res[2]-res[1] == 1, "step size")
checkEqualsNumeric(res, 20:30, "values")
