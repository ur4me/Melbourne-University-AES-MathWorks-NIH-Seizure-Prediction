# get ccf and its lag # time consuming
ccf = matrix(,1, 15 * 16/2)
lag = matrix(,1, 15 * 16/2)
k = 0
for ( i in 1: (ncol(df2)-1)){
  for (j in (i+1): ncol(df2)){
    k = k+1
    ccf_max = Find_Max_CCF(df2[,i],df2[,j])
    ccf[1,k] = ccf_max$cor
    lag[1,k] = ccf_max$lag
  }
}
trainset[n,] = c(targets[[1]][4],target,mean_list,median_list,sem_list,abssum_list,as.numeric(cor),as.numeric(dist),as.numeric(ccf),as.numeric(lag))
}
}

write.table(trainset,output,quote=F,row.names=F,col.names=T,sep=",")