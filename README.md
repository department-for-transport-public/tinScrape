# tinScrape

## Installing tinScrape

To install the tinScrape package use:

```
install.packages("remotes")
remotes::install_github("department-for-transport-public/tinScrape")
```

## What is tinScrape?

The tinScrape package is made up of several functions that focuses on:

* webscraping information and downloadable hyperlinks from GOV.UK
* extracting information in Excel worksheets
* transforming data tables into a tidy format, that is a long format
* automating the migration of data stored in Google Cloud Storage (GCS) buckets into BigQuery (BQ)

The package complements and supports the development and maintenance of the Department for Transport's currently internal-facing website - Transport in Numbers (TiN).

## Functions included

Currently, tinScrape is made up of the following main functions:

* `extract_table_urls`
* `gcp_to_bq`
* `scrape_dynamic_methodology`
* `scrape_orr_tables`
* `utils`

### gcp_to_bq

You can call this function using the following line:

```
tinScrape::gcp_to_bq()
```

This function takes a published data table, if it exists in GCS, extracts all the worksheets within the document, tidies the data and stores the final output in BQ. To do this, it calls on 3 other functions, created specifically for TiN:

* `gcp_tables_to_list`
* `tidied_df`
* `create_bq_table`

Further information about each of these functions are below.

The argument required for the function is the name of the Excel file. If the function does not seem to work, check the GCS storage bucket to see if the Excel file's name you are trying to call matches with what is in the bucket.

The `gcp_to_bq()` ensures the input - the name of the Excel file - is set to be uppercase, so the function is case insensitive. 

#### gcp_tables_to_list

You can call this function using the following line:

```
tinScrape::gcp_tables_to_list()
```

For a given Excel document, this function searches for that document in GCS and reads it into R. Each marked up table in the document are outputted as lists in the R environment, where the name of the list is the worksheet's name.

The argument required for the function is the name of the Excel file. If the function does not seem to work, check the GCS storage bucket to see if the Excel file's name you are trying to call matches with what is in the bucket.

Due to this function being part of the `gcp_to_bq()` function, the arguments stated above do not need to be manually inputted as this is automated and the input is case insensitive.

#### tidied_df

You can call this function using the following line:

```
tinScrape::tidied_df()
```

This function automates the conversion of data tables from the format they are found in the Excel document (usually wide format) to long format.

The function also strips additional information from the table (such as notes and shorthand notation) and converts column headings to be written in a tidy, consistent format (in this case, snake-case with underscores). The latter ensures it meets BQ requirements for column headings, which prevents special characters and similar from being used.

The argument required for the function is the data table, that would have been read into R using the `gcp_tables_to_list()`. 

Due to this function being part of the `gcp_to_bq()` function, the arguments stated above do not need to be manually inputted as this is automated and the input is case insensitive.

The tidying of the data table's format is done by identifying when the last qualitative or time period column is. Most of the time, data tables either has:

* a time period column in the first column which precedes the quantitative data,
* columns with qualitative data which precedes the quantitative data, or
* a time period column, qualitative data and then the quantitative data

The location of the first column of quantitative data is identified, and is then pivoted to the long format desired. This is done using the `year_column_check()` function which is called on as part of the `tidied_df()` function.



#### create_bq_table

You can call this function using the following line:

```
tinScrape::create_bq_table()
```

This function exports the tidied data to BQ. It checks if the data table already exists in BQ so it can truncate/overwrite the data in it. It is set up this way to ensure the latest information is always reflected in BQ. Otherwise it will create a new table in the `dft-stats-diss-dev` dataset in BQ and populate it with the data.

Arguments required are:

* the name of tidied data
* the name of the worksheet, found in the Excel document
* the name of the Excel document

Due to this function being part of the `gcp_to_bq()` function, the arguments stated above do not need to be manually inputted as this is automated.
