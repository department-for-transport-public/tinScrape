# Extract metadata from the most recent ORR files in a Google Cloud Storage bucket

This function extracts metadata from the most recent \`.ods\` ORR files
in a specified Google Cloud Storage (GCS) bucket. It uses the
\`download_orr_cover\` function to retrieve the cover sheet metadata
(emails and dates) and processes it into a tidy format.

## Usage

``` r
extract_orr_metadata(bucket_name = "tin_dev_orr_storage")
```

## Arguments

- bucket_name:

  A string representing the name of the GCS bucket from which the
  metadata will be extracted.

## Value

A tibble containing the metadata (e.g., email, next_update, last_update)
from the most recent \`.ods\` files.
