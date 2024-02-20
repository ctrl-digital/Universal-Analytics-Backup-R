split_date_range <- function(start_date, end_date, interval = "1 months") {
  dates <- seq(as.Date(start_date), as.Date(end_date), by = interval)
  if(end_date != tail(dates, 1)) {
    dates <- c(dates, as.Date(end_date))
  }
  intervals <- data.frame(start = head(dates, -1), end = tail(dates, -1) -1)
  return(intervals)
}

fetch_ga_data <- function(start_date, end_date, ga_id, metrics, dimensions) {
  df <- google_analytics(
    ga_id,
    date_range = c(start_date, end_date),
    metrics = metrics,
    dimensions = dimensions,
    anti_sample = TRUE
  )
  
  return(df)
}

fetch_and_cache_data <- function(table_name, metrics, dimensions, date_intervals, ga_id, pb, start_date, end_date) {
  # Initialize an empty dataframe to hold cached data
  cached_data <- data.frame()
  last_fetched_date <- NULL # Initialize last_fetched_date before the loop
  
  for (i in 1:nrow(date_intervals)) {
    interval_start <- as.character(date_intervals$start[i])
    interval_end <- as.character(date_intervals$end[i])
    
    # Only fetch new data if cache is empty or interval is beyond last fetched date
    if (is.null(last_fetched_date) || as.Date(interval_end) > as.Date(last_fetched_date)) {
      cat("Fetching data for", table_name, ":", interval_start, "to", interval_end, "\n")
      
      table_data <- fetch_ga_data(
        interval_start, interval_end, ga_id,
        metrics, dimensions
      )
      
      # Combine new data with cached data
      cached_data <- rbind(cached_data, table_data)
      
      # Update last fetched date to the end of the current interval
      last_fetched_date <- interval_end
      
      if (!is.null(pb)) {
        pb$tick()
      }
    }
  }
  
  return(cached_data)
}


upload_to_bq_in_batches <- function(df, table_name, billing_project_id, dataset_id, batch_size = 200000) {
  n_batches <- ceiling(nrow(df) / batch_size)
  for (i in 1:n_batches) {
    start_row <- ((i-1) * batch_size) + 1
    end_row <- min(i * batch_size, nrow(df))
    df_batch <- df[start_row:end_row, ]
    bq_table <- bq_table(project = billing_project_id, dataset = dataset_id, table = table_name)
    handle <- new_handle(timeout = 600)  
    if (i == 1) {
      bq_table_upload(bq_table, df_batch, create_disposition = "CREATE_IF_NEEDED", write_disposition = "WRITE_TRUNCATE")
    } else {
      bq_table_upload(bq_table, df_batch, create_disposition = "CREATE_IF_NEEDED", write_disposition = "WRITE_APPEND")
    }
    Sys.sleep(3)
  }
}

