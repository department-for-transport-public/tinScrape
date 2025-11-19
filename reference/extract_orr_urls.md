# For a provided url, return a table of urls of uploaded ODS and CSV files

For a provided url, return a table of urls of uploaded ODS and CSV files

## Usage

``` r
extract_orr_urls(
  url = "https://dataportal.orr.gov.uk/statistics/usage/passenger-rail-usage/"
)
```

## Arguments

- url:

  URL of the web page to scrape urls from.

## Value

a table containing three columns, the collection url, the document url
and the time of collection
