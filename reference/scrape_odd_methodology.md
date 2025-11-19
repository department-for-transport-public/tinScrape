# For a provided url, return those stats which have dynamically updating methodology links

For a provided url, return those stats which have dynamically updating
methodology links

## Usage

``` r
scrape_odd_methodology(
  url =
    "https://www.gov.uk/government/organisations/department-for-transport/about/statistics"
)
```

## Arguments

- url:

  URL of the web page to scrape urls from. Defaults to the gov.uk stats
  homepage

## Value

a table containing two columns, the collection url and the methodology
url
