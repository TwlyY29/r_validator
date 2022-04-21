################################
# DO NOT MODIFY THIS BLOCK!
# id: 345678
# created: 2022-04-21
# achievable score: 13
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



