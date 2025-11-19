# For a provided url, return a table of urls of uploaded ODS and CSV files

For a provided url, return a table of urls of uploaded ODS and CSV files

## Usage

``` r
extract_table_urls(
  url =
    "https://www.gov.uk/government/organisations/department-for-transport/about/statistics"
)
```

## Arguments

- url:

  URL of the web page to scrape urls from. Defaults to the gov.uk stats
  homepage

## Value

a table containing three columns, the collection url, the document url
and the time of collection
