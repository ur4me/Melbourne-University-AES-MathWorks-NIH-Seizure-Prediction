trainset = matrix(,length(filenames),(16*4 + 120 *4+2))
trainset = as.data.frame(trainset)
length =length(filenames)
colnames(trainset) = c("id","target",paste("mean_",rep(1:16),sep=""),paste("median_",rep(1:16),sep=""),paste("sem_",rep(1:16),sep=""),paste("abssum_",rep(1:16),sep=""),paste("cor_",rep(1:120),sep=""),paste("dist_",rep(1:120),sep=""),paste("ccf_",rep(1:120),sep=""),paste("lag_",rep(1:120),sep=""))

#for (n in 1: length(filenames)){
for (n in 1: 2){
  if(n%% 2==1){cat(n,"\t",n/length,"\n")}
  targets = strsplit(filenames[n],"/")
  name = strsplit(targets[[1]][4],"_")
  target = strsplit(name[[1]][3],".mat")
  data = readMat(filenames[n])
  df = as.data.frame(data[[1]][[1]])
  # filter any time point ==0
  ##Go through each row and determine if a value is zero
  row_sub = apply(df, 1, function(row) all(row !=0 ))
  ##Subset as usual
  df = df[row_sub,]
  if( nrow(df)==0){
    # filter all channel ==0
    trainset[n,] = c(targets[[1]][4],target, rep(0, (ncol(trainset)-2)))
  }
  else{
    ## get min and max to normalize df2 as bellow
    min_list = as.numeric(apply(df, 2, min))
    max_list = as.numeric(apply(df, 2, max))
    min_all = rep(min_list, each =nrow(df))
    max_all = rep(max_list, each =nrow(df))
    # normalize df2 as bellow
    df2 = (df -min_all)/(max_all - min_all)
    
    # get unique feature
    sum_list = as.numeric(apply(df2, 2, sum))
    mean_list = as.numeric(apply(df2, 2, mean))
    median_list = as.numeric(apply(df2, 2, median))
    sem_list = as.numeric(apply(df2, 2, function (x) {sd(x)/length(x)}))
    abssum_list = as.numeric(apply(df2, 2, function (x) {sum(abs(x))}))
    
    ## get correlation between channels
    cor = matrix(,1, 15 * 16/2)
    k = 0
    for ( i in 1: (ncol(df2)-1)){
      for (j in (i+1): ncol(df2)){
        k = k+1
        cor[1,k] = cor(df2[,i],df2[,j])
      }
    }