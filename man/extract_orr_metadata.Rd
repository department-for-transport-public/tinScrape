% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metadata_orr_scrape.R
\name{extract_orr_metadata}
\alias{extract_orr_metadata}
\title{Extract metadata from the most recent ORR files in a Google Cloud Storage bucket}
\usage{
extract_orr_metadata(bucket_name = "tin_dev_orr_storage")
}
\arguments{
\item{bucket_name}{A string representing the name of the GCS bucket from which the metadata will be extracted.}
}
\value{
A tibble containing the metadata (e.g., email, next_update, last_update) from the most recent `.ods` files.
}
\description{
This function extracts metadata from the most recent `.ods` ORR files in a 
specified Google Cloud Storage (GCS) bucket. It uses the `download_orr_cover` 
function to retrieve the cover sheet metadata (emails and dates) and processes 
it into a tidy format.
}
