@IF_FUN read_data_iris@
data <- read_data_iris()
plot(data$Sepal.Width, data$Sepal.Length, col=data$Species, main="Sepal Width and Length")
@ENDIF@
@IF_FUN read_data_cars@
data <- read_data_cars()
plot(data$wt, data$mpg, col=data$cyl, main="Weight and Miles per Gallon")
@ENDIF@
