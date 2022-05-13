checkSourceContains("read.csv(","used base read function",fname="@FNAME@")
checkTrue(all(c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width","Species") %in% colnames(res)), "correct column names")
checkTrue(is.factor(res$Species), "strings are factors")
