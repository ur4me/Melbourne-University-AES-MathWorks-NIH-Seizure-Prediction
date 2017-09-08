# window stats
v_min <- c(v_min, min(window))
v_max <- c(v_max, max(window))
v_mean <- c(v_mean, mean(window))
v_median <- c(v_median, median(window))
v_sem <- c(v_sem, sd(window)/length(window))
v_abssum <- c(v_abssum, sum(abs(window)))
}
trainset[n_window_id,] = c(id,
                           target,
                           n_window_id,
                           n_seg_num,
                           v_min,
                           v_max,
                           v_mean,
                           v_median,
                           v_sem,
                           v_abssum)

}

trainset
}

process_file_windows_single <- function(filename) {
  # parse the 'preictal, interical' label
  data = readMat(filename)
  s_base_filename <- basename(filename)
  v_filename_parts <- strsplit(s_base_filename, "_")[[1]]
  s_target <- v_filename_parts[3]
  s_target <- gsub(".mat", "", s_target)
  n_seg_num <- as.numeric(v_filename_parts[2])
  
  # calculate window features
  trainset <- process_windows(data = data, id=s_base_filename, target=s_target, n_seg_num=n_seg_num)
  
  trainset
}

process_windows_parallel <- function(inputdir="../input/train_1.small/",
                                     output_filename="../data/features/train_1_windows_set.txt",
                                     cores=4,
                                     limit=0) {
  filenames <- list.files(inputdir, pattern="*.mat", full.names=TRUE)
  if (limit > 0) {
    filenames = head(filenames, limit)
  }
  
  runtime <- system.time({
    trainset <- mclapply(filenames, process_file_windows_single, mc.cores = cores)
  })[3]
  print(sprintf("runtime: %s", runtime))
  print(sprintf("length: %s", length(trainset)))
  df <- do.call("rbind", trainset)
  
  v_names <- c("id", "target", "window_id", "segnum",
               paste("min_", 1:16, sep=""), 
               paste("max_", 1:16, sep=""), 
               paste("mean_", 1:16, sep=""), 
               paste("median_", 1:16, sep=""), 
               paste("sem_", 1:16, sep=""), 
               paste("abssum_", 1:16, sep=""))
  print(sprintf("Dimensions: %s", paste(dim(df), collapse="x ")))
  colnames(df) <- v_names
  
  # sort by target then segment number
  ord = order(df$target, df$segnum, decreasing = F)
  df <- df[ord,]