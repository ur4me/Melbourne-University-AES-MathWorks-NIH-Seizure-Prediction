# Extract basic statistics from each window using parallel processing to speed up extraction

library("parallel")
library("R.matlab")
library("ggplot2")
library("gridExtra")
library("dplyr")

process_windows <- function(data, id, target, n_seg_num, secs_per_window=10) {
  # (2) nSamplesSegment: total number of time samples (number of rows in the data field).
  # (3) iEEGsamplingRate: data sampling rate, i.e. the number of data samples 
  #   representing 1 second of EEG data. 
  # (4) channelIndices: an array of the electrode indexes corresponding to 
  #     the columns in the data field.
  df_eeg = as.data.frame(data[[1]][[1]])
  iEEGsamplingRate <- data$dataStruct[[2]][1]
  nSamplesSegment <- data$dataStruct[[3]][1]
  channelIndices <- data$dataStruct[[4]]
  n_num_channels <- length(channelIndices)
  
  n_num_windows <- (nSamplesSegment/iEEGsamplingRate) / secs_per_window
  
  # nsamples for a 10 second window
  n_samples_per_window <- iEEGsamplingRate * secs_per_window
  n_window_id <- 0
  
  # data (16 channels, 6 stats) + (id, target, window_id, segnum)
  trainset = matrix(,n_num_windows,(16*6+4))
  trainset = as.data.frame(trainset)
  
  # window_id, min, max, mean, median, 
  for (n_offset in seq(1, nSamplesSegment, n_samples_per_window)) {
    n_window_id <- n_window_id + 1
    
    v_mean <- c()
    v_median <- c()
    v_sem <- c()
    v_abssum <- c()
    v_min <- c()
    v_max <- c()
    
    # beginning and end of window
    n_offset_end <- n_offset+n_samples_per_window - 1