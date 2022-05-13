################################
# DO NOT MODIFY THIS BLOCK!
# id: 345678
# created: 2022-05-13
# achievable score: 29
# DO NOT MODIFY THIS BLOCK! 
################################


# Task 1:
# 3 Points
# Create and return a sequence of whole numbers from 10 to 20.
#
# Do NOT change the following line
create_sequence_from_10_to_20 <- function(){
  c(10:20)
}
create_sequence_from_10_to_20()

# Task 2:
# 3 Points
# Create and return a sequence of whole numbers from 20 to 30.
#
# Do NOT change the following line
create_sequence_from_20_to_30 <- function(){
  c(20:30)
}
create_sequence_from_20_to_30()

# Task 3:
# 3 Points
# Create and return a sequence of whole numbers from 40 to 80.
# Make sure to use 'seq' and a step size of 2.
#
# Do NOT change the following line
create_sequence_from_40_to_80 <- function(){
  seq(40,80,2)
}
create_sequence_from_40_to_80()

# Task 4:
# 2 Points
# Sum 4th and 6th position in vector 'vec'
#
# Do NOT change the following line
sum_4th_and_6th_position <- function(vec){
  vec[4]+vec[6]
}
sum_4th_and_6th_position(vec=c(10:20))

# Task 5:
# 2 Points
# Sum 4th and 6th position in vector 'vec'
#
# Do NOT change the following line
sum_vec1_and_vec2_without_plus <- function(vec1,vec2){
  sum(vec1,vec2)
}
sum_vec1_and_vec2_without_plus(vec1=c(10:20),vec2=c(20:30))

# Task 6:
# 4 Points
# Plot a pie chart. Assign labels to the plots. And give a speaking title.
#
# Do NOT change the following line
plot_pie_chart <- function(data, labels, main){
  data=c(10,15,25,30,10,10)
  labels=LETTERS[1:6]
  main="bla, fasel"
  pie(data, labels = labels, main = main)
}
plot_pie_chart(data=c(10,15,25,30,10,10), labels=LETTERS[1:6], main="bla, fasel")

# Task 7:
# 4 Points
# Plot a barplot. Assign labels to the plots. And give a speaking title.
# Make sure the plot is saved to the png file
#
# Do NOT change the following line
plot_barplot_to_png <- function(data, labels){
  png("test.png", width=320, height=240)
  barplot(data, names.arg = labels, main = "Shares from A to Z")
  dev.off()
}
plot_barplot_to_png(data=c(10,15,25,30,10,10), labels=LETTERS[1:6])

# Task 8:
# 3 Points
# Read in the dataset https://teaching.mircoschoenfeld.de/datasets/cars.csv
#
# Do NOT change the following line
read_data_cars <- function(){
  read.csv("https://teaching.mircoschoenfeld.de/datasets/cars.csv", sep=";")
}
read_data_cars()

# Task 9:
# 5 Points
# Visualize the data you read in in the previous task.
#
# Do NOT change the following line
plot_data <- function(){
  data <- read_data_cars()
  plot(data$wt, data$mpg, col=data$cyl, main="Weight and Miles per Gallon")
}
plot_data()



