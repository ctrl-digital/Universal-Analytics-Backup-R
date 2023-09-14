# Universal Analytics to BigQueryexport.

## Description
Run this R script to export Universal Analytics data to Google BigQuery. It will not be a comprehensive (include-all) backup. Instead, you have to define your wanted dimensions & metrics.
Preferably, you can create multiple tables for different scopes and purposes, e.g “products”, for product data, “events” for event data etc.

## Prerequisites

### Software and services

* RStudio and or R.
* A Google Cloud Platform project with BigQuery enabled.
* Data in Universal Analytics.
* Service account or JSON key to access Google Cloud Platform account.

### Libraries in R

The following libraries are needed in R,

bigrquery, googleAnalyticsR, lubridate,
dplyr, progress, purrr, curl

and are installed with the command 
```R
install.packages("bigrquery")
install.packages("googleAnalyticsR")
...
```


## Usage

* In the main.R file you need to enter the path to your JSON key for your service account.
* Change billing project, dataset id, google analytics id, start and end dates.
* Change the tables list to reflect the metrics and dimensions you wish to backup.
* Run the script in main.R


