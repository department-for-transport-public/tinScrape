# Tidies tables in ODS workbooks and converts to long format

Tidies tables in ODS workbooks and converts to long format

## Usage

``` r
tidied_df(data)
```

## Arguments

- data:

  Name of the dataset to tidy, which will be the name of the worksheet
  in the ODS workbook

## Value

A tidied, long table that has a value and grouped_var column, and a
column stating the date and time of when the dataset was tidied, at a
minimum
