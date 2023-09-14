split_date_range <- function(start_date, end_date, interval = "1 months") {
  dates <- seq(as.Date(start_date), as.Date(end_date), by = interval)
  if(end_date != tail(dates, 1)) {
    dates <- c(dates, as.Date(end_date))
  }
  intervals <- data.frame(start = head(dates, -1), end = tail(dates, -1) -1)
  return(intervals)
}

fetch_ga_data <- function(start_date, end_date, ga_id, pb, metrics, dimensions) {
  df <- google_analytics(
    ga_id,
    date_range = c(start_date, end_date),
    metrics = metrics,
    dimensions = dimensions,
    anti_sample = TRUE)
  
  return(df)
}

fetch_and_cache_data <- function(table_name, metrics, dimensions, date_intervals, ga_id, pb, start_date, end_date) {
  cached_data <- list()
  last_fetched_date <- NULL
  
  for (i in 1:nrow(date_intervals)) {
    interval_start <- as.character(date_intervals$start[i])
    interval_end <- as.character(date_intervals$end[i])
    
    if (!is_empty(cached_data)) {
      last_cached_date <- tail(cached_data$date, 1)
      if (as.Date(interval_start) <= as.Date(last_cached_date)) {
        cached_rows_count <- nrow(cached_data)
        unique_rows_count <- length(unique(cached_data$date))
        missing_rows_count <- cached_rows_count - unique_rows_count
        
        if (missing_rows_count > 0) {
          cat("Fetching missing rows for", table_name, ":", interval_start, "to", interval_end, "(", missing_rows_count, "missing rows)\n")
        }
        next
      }
    }
    
    table_data <- fetch_ga_data(
      interval_start, interval_end, ga_id, pb,
      metrics, dimensions
    )
    
    cached_data <- rbind(cached_data, table_data)
    
    last_fetched_date <- interval_end
    
    pb$tick()
  }
  
  return(cached_data)
}



upload_to_bq_in_batches <- function(df, table_name, billing_project_id, dataset_id, batch_size = 2000000) {
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

