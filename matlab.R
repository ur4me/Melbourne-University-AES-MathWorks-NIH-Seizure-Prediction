Find_Max_CCF<- function(a,b)
{
  d <- ccf(a, b, plot = FALSE)
  cor = d$acf[,,1]
  lag = d$lag[,,1]
  res = data.frame(cor,lag)
  res_max = res[which.max(res$cor),]
  return(res_max)
}

library("R.matlab")

#args <- commandArgs(T)
#if (length(args) < 2) {
#    cat("USAGE: miss args")
#    q()
#}
#input <- args[1]
#output <- args[2]

input = "../input/train_1"
output = "train_1_features.csv"
filenames <- list.files(input, pattern="*.mat", full.names=TRUE)