# check for data drop-out, where values across all channels are 0
window_all_channels <- df_eeg[n_offset:n_offset_end, ]
if (! all(dim(window_all_channels) == c(n_samples_per_window, n_num_channels))){
  stop(sprintf("[process_windows] %s: Bad Dimensions: %s", id, paste(dim(window_all_channels), collapse="x ")))                            
}

li_absum_by_row <- as.numeric(apply(window_all_channels, 
                                    1,
                                    function (x) sum(abs(x))))
n_dropout_rows <- sum(li_absum_by_row == 0)

if (n_dropout_rows > 0) {
  print(sprintf("[process_windows] %s: n_dropout_rows = %s", id, n_dropout_rows))
}

v_dropout_rows <- (li_absum_by_row == FALSE)

if (n_dropout_rows > 3500) {
  print(sprintf("[process_windows] - too many dropout rows in window: %s", n_window_id))
  trainset[n_window_id,] = c(id,
                             target,
                             n_window_id,
                             n_seg_num,
                             rep(NA, n_num_channels),
                             rep(NA, n_num_channels),
                             rep(NA, n_num_channels),
                             rep(NA, n_num_channels),
                             rep(NA, n_num_channels),
                             rep(NA, n_num_channels))
  next
  
} 

for (n_channel in channelIndices) {
  # 10-sec window for channel
  window <- df_eeg[n_offset:n_offset_end, n_channel]
  
  if( n_dropout_rows > 0) {
    # remove dropout rows
    window <- window[! v_dropout_rows]
  }
  
  if (length(window) != (n_samples_per_window - n_dropout_rows)) {
    print(sprintf("window_id: %s, channel_id: %s", n_window_id, n_channel))
    print(sprintf("n_offset: %s, n_offset:end : %s", n_offset, 
                  n_offset+n_samples_per_window))
    stop(sprintf("[process_windows] - invalid window length. Expected: %s, Found: %s",
                 n_samples_per_window - n_dropout_rows,
                 length(window)))
  }