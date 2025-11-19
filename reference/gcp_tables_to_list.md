# To tidy published DfT data, stored in GCP, and move to BigQuery

To tidy published DfT data, stored in GCP, and move to BigQuery

## Usage

``` r
gcp_tables_to_list(file_name, bucket_name)
```

## Arguments

- file_name:

  DfT code for published table.

- bucket_name:

  Name of the GCS bucket that contains the data to be moved into BQ.
  Locations that exist are "tin_dev_data_storage" for DfT tables and
  "tin_dev_orr_storage" for ORR tables.

## Value

A list of raw data tables from the file in question, with one table per
list item.
