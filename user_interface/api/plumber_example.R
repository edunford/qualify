# Temp API

#* A meaningless input
#* @param msg The message to echo
#* @get /posts
function(msg){
  print(msg)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /happy
function(a, b){
  as.numeric(a) + as.numeric(b)
}
