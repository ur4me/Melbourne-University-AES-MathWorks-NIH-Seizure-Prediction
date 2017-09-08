## get E distance between two channels
dist = matrix(,1, 15 * 16/2)
k = 0
for ( i in 1: (ncol(df2)-1)){
  for (j in (i+1): ncol(df2)){
    k = k+1
    dist[1,k] = sqrt(sum((df2[,i]-df2[,j])^2))
  }
}
