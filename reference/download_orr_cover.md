# Download the cover sheet from a published ORR table

This function downloads the most recent ORR table that matches the
provided name from a Google Cloud Storage (GCS) bucket and extracts the
cover sheet containing relevant metadata such as emails and dates.

## Usage

``` r
download_orr_cover(df_name, bucket_name = "tin_dev_orr_storage")
```

## Arguments

- df_name:

  A string representing the name of the ORR table to be downloaded. The
  function will look for tables in the specified GCS bucket that match
  this string (case-insensitive).

- bucket_name:

  A string representing the name of the GCS bucket from which the table
  will be downloaded. Default is \`"tin_dev_orr_storage"\`.

## Value

A tibble containing two types of metadata: - Emails: rows containing
email addresses found on the cover sheet. - Dates: rows containing date
information found on the cover sheet. If no cover sheet is found, the
tibble will contain \`NA\` values for the columns \`info\`, \`text\`,
and \`source\`.
