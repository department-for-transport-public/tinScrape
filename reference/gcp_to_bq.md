# To tidy published DfT data, stored in GCP, and move to BigQuery

To tidy published DfT data, stored in GCP, and move to BigQuery

## Usage

``` r
gcp_to_bq(file_name, bucket_name)
```

## Arguments

- file_name:

  DfT or ORR code for published table.

- bucket_name:

  Name of the GCS bucket that contains the data to be moved into BQ.
  Locations that exist are "tin_dev_data_storage" for DfT tables and
  "tin_dev_orr_storage" for ORR tables.

## Value

A tidied, machine readable version of the table, in a long format, in
BQ.
