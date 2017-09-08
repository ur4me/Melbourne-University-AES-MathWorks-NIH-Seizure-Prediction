# write to file
print(sprintf("Writing features to : %s", output_filename))
write.table(df, output_filename,
            quote=F,row.names=F,col.names=T,sep="\t")
df
}

load_window_features <- function(output_filename="../data/features/train_1_windows_set.txt") {
  df <- read.table(output_filename, header=T, stringsAsFactors = F)
  df$segnum <- as.numeric(df$segnum)
  df$target <- as.numeric(df$target)
  
  # sort by target then segment number
  ord = order(df$target, df$segnum, decreasing = F)
  df <- df[ord,]
  df
}


##
# Functions to plot the features
###

plot_feature_for_channel <- function(df, offset, channel=1, label="min") {
  n_colnum <- offset + channel
  v_channel_data <- as.numeric(df[,n_colnum])
  
  datums <- data.frame(channel_data=v_channel_data,
                       times=seq(length(v_channel_data)),
                       target=df$target)
  
  obj <- ggplot(datums, aes(x=times, y=channel_data, color=target)) + 
    geom_line() + 
    ylab(sprintf("%s-%s", label, channel)) +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          legend.position="none")
  obj
}


plot_feature_mean_channels <- function(df, num_channels=16, output_png="mean_eeg_channels.png") {
  offset=36
  l_plots <- list()
  
  for (n_channel in seq(num_channels)) {
    plt <- plot_feature_for_channel(df, offset = offset, channel = n_channel, label="mean" )
    l_plots <- c(l_plots, list(plt))
  }
  
  print(length(l_plots))
  do.call(grid.arrange, c(l_plots, top="MEAN per iEEG channel ('interical', 'preictal')"))
  dev.copy(png, width = 960, height = 960, units = "px", output_png)
  dev.off()
  output_png
}

parallel_feature_extractor_example <- function(cores=8,
                                               inputdir="../data/train_1.small/",
                                               output_filename="../data/features/train_1_windows_set.txt",
                                               limit=100) {
  
  df <- process_windows_parallel(cores=cores, inputdir = inputdir, output_filename = output_filename, limit=limit)
  
  df$segnum <- as.numeric(df$segnum)
  df$target <- as.numeric(df$target)
  
  # sort by target then segment number
  ord = order(df$target, df$segnum, decreasing = F)
  df <- df[ord,]
  
  # Generate mean for each window for each channel
  plot_filename <- plot_feature_mean_channels(df, output_png="./mean_eeg_channels.png")
  
  print(sprintf("Created MEAN plot : %s", plot_filename))
}


# run the feature extractor using parallel processes. 
# limit to 100 files, to speed up running a the kernel (set to 0 to process all files)
parallel_feature_extractor_example(cores=detectCores(), 
                                   inputdir="../input/train_1", 
                                   output_filename="./train_1_windows_set_small.txt", 
                                   limit=100)
system("ls ./*.png")
system("ls ./*.txt")

