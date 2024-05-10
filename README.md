# Universal Analytics to BigQuery export.

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

1. Download RStudio https://posit.co/download/rstudio-desktop/ and open it
2. Import or copy the main.r script into your workspace
3. Install all of the packages following the instructions above
4. Now run main.r row by row, when you get to row 11, you will be prompted to use OAuth by default.
   Here you have to pick the google account that has access to your bigquery project, and your google analytics project.
5. On rows 13-15 you have to add the information that tells the script where to put the exported data in BigQuery and which UA property it should export from.
   You also choose the start and end date for the exported data on rows 16, 17.
   The billing project id can be found under "billing projects" in GCP. Important to note is that it's not the "Billing account ID".
6. If there isn't already a dataset designated for the export in BigQuery, you can create a new one. If you then press it, you will see the "Dataset ID" under Dataset info".
   You do not need to add the full ID. Only the part after the dot (.).
   The value that should go under "ga_id" can be found in your google analytics interface under your Analytics Accounts->Properties & Apps->Views.
   Here you will find a numerical ID for the view that you would like to export.
7. Now its time to pick which data you would like to export, this is done on the rows 21-31, beginning with the definition of tables <- list(...
   The default code only has one list, which will create 1 table in BigQuery with the name "product_table".
   To pick the right metrics and dimensions to each table, use this tool, and make sure to toggle in the left corner to UA.
   https://ga-dev-tools.google/dimensions-metrics-explorer/
   Once you are happy with your metrics and dimensions, keep running the script row by row.
8. Before you run row 49, you should be positive that the data you have chosen is the data that you want to upload to BigQuery.
   Once you are sure, go ahead and run row 49, which will start uploading data to BigQuery (note that this can take some time, do not exit the program).




