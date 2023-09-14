library(bigrquery)
library(googleAnalyticsR)
library(lubridate)
library(dplyr)
library(progress)
library(purrr)
library(curl)

source("https://raw.githubusercontent.com/ctrl-digital/Universal-Analytics-Backup-R-/main/functions.r")

bq_auth(path = 'Path_to_your_auth_key')

billing_project_id <- 'project_id'
dataset_id <- "CTRL_ua_backup"
ga_id <- 1337
start_date <- '2019-01-01'
end_date <- '2019-07-21'

date_intervals <- split_date_range(start_date, end_date)

tables <- list(
  product_table = list(
    # Here you can add your metrics and dimensions that you require
    metrics = c("ga:productAddsToCart", "ga:uniquePurchases", "ga:itemRevenue", "ga:productDetailViews", "ga:productCheckouts", "ga:itemQuantity"),
    dimensions = c("date", "ga:productSku", "ga:productName", "ga:productBrand", "ga:productVariant", "ga:productCategoryHierarchy")
  )
  #device_category_test = list(
  #  metrics = c("sessions", "bounces", "transactions", "transactionRevenue"),
  #  dimensions = c("date", "deviceCategory")
  #)
)

pb <- progress_bar$new(total = length(tables) * nrow(date_intervals), format = "[:bar] :percent")

cached_data <- list()
for (table_name in names(tables)) {
  table_info <- tables[[table_name]]
  metrics <- table_info$metrics
  dimensions <- table_info$dimensions
  
  if (exists("last_fetched_date")) {
    start_date <- last_fetched_date
    rm(last_fetched_date)
  }
  
  cached_data[[table_name]] <- fetch_and_cache_data(table_name, metrics, dimensions, date_intervals, ga_id, pb, start_date, end_date)
}

for (table_name in names(cached_data)) {
  upload_to_bq_in_batches(cached_data[[table_name]], table_name, billing_project_id, dataset_id)
}

