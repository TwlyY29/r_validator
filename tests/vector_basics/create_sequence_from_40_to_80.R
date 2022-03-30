checkTrue(res[2]-res[1] == 2, "step size")
checkEqualsNumeric(res, seq(40,80,2), "values")
checkSourceContains("seq(", "use seq function", fixed=T)
