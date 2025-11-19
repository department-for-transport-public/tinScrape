# tinScrape

## Installing tinScrape

To install the tinScrape package use:

    install.packages("remotes")
    remotes::install_github("department-for-transport-public/tinScrape")

## What is tinScrape?

The tinScrape package is made up of several functions that focuses on:

- webscraping information and downloadable hyperlinks from GOV.UK
- extracting information in Excel worksheets
- transforming data tables into a tidy format, that is a long format
- automating the migration of data stored in Google Cloud Storage (GCS)
  buckets into BigQuery (BQ)

The package complements and supports the development and maintenance of
the Department for Transport’s currently internal-facing website -
Transport in Numbers (TiN).

## Functions included

Currently, tinScrape is made up of the following main functions:

- `extract_table_urls`
- `extract_metadata`
- `gcp_to_bq`
- `scrape_dynamic_methodology`
- `scrape_orr_tables`

### extract_table_urls

You can call this function using the following line:

    tinScrape::extract_table_urls()

This function webscrapes the downloadable hyperlinks for published data
tables from the Stats at DfT GOV.UK webpage. The function calls on other
functions that are found in the utils.R script which are designed to
extract hyperlinks that pertain to statistical outputs only
(specifically the
[`collect_collections()`](https://department-for-transport-public.github.io/tinScrape/reference/collect_collections.md),
[`collect_links()`](https://department-for-transport-public.github.io/tinScrape/reference/collect_links.md)
and
[`scrape_tables()`](https://department-for-transport-public.github.io/tinScrape/reference/scrape_tables.md)
functions).

For downloadable documents, such as Excel files, the
[`extract_table_urls()`](https://department-for-transport-public.github.io/tinScrape/reference/extract_table_urls.md)
function takes into account the different formats for these URLs:
numbers or hexidecimal values. A combination of both are used on GOV.UK.

No argument is required to use this function as the Stats at DfT webpage
is hardcoded into the function in the first instance.

### extract_metadata

You can call this function using the following line:

    tinScrape::extract_metadata()

This functions utilises the
[`download_cover()`](https://department-for-transport-public.github.io/tinScrape/reference/download_cover.md)
function to read and extract a publication’s metadata on an ODS’ Cover
sheet. For the purposes of TiN, this covers the email address and date
of publication.

The function reads in the data saved in GCS, extracts the information
after identifying the Cover sheet and saves it in a dataframe. A
separate chunk of code is then required to be run for this information
to be exported to BQ. This is provided below:

`bigrquery::bq_table_upload("[name of BQ table]", tinScrape::extract_metadata(), create_disposition='CREATE_IF_NEEDED', write_disposition = "WRITE_TRUNCATE")`

Equivalent functions to extract and export the metadata from ORR tables
exist, and are
[`extract_orr_metadata()`](https://department-for-transport-public.github.io/tinScrape/reference/extract_orr_metadata.md)
and
[`download_orr_cover()`](https://department-for-transport-public.github.io/tinScrape/reference/download_orr_cover.md).

### gcp_to_bq

You can call this function using the following line:

    tinScrape::gcp_to_bq()

This function takes a published data table, if it exists in GCS,
extracts all the worksheets within the document, tidies the data and
stores the final output in BQ. To do this, it calls on 3 other
functions, created specifically for TiN:

- `gcp_tables_to_list`
- `tidied_df`
- `create_bq_table`

Further information about each of these functions are below.

The argument required for the function is the name of the Excel file. If
the function does not seem to work, check the GCS storage bucket to see
if the Excel file’s name you are trying to call matches with what is in
the bucket.

The
[`gcp_to_bq()`](https://department-for-transport-public.github.io/tinScrape/reference/gcp_to_bq.md)
ensures the input - the name of the Excel file - is set to be uppercase,
so the function is case insensitive.

#### gcp_tables_to_list

You can call this function using the following line:

    tinScrape::gcp_tables_to_list()

For a given ODS document, this function searches for that document in
GCS and reads it into R. Each marked up table in the document are
outputted as lists in the R environment, where the name of the list is
the worksheet’s name.

The argument required for the function is the name of the ODS file. If
the function does not seem to work, check the GCS storage bucket to see
if the ODS file’s name you are trying to call matches with what is in
the bucket.

Due to this function being part of the
[`gcp_to_bq()`](https://department-for-transport-public.github.io/tinScrape/reference/gcp_to_bq.md)
function, the arguments stated above do not need to be manually inputted
as this is automated and the input is case insensitive.

#### tidied_df

You can call this function using the following line:

    tinScrape::tidied_df()

This function automates the conversion of data tables from the format
they are found in the Excel document (usually wide format) to long
format.

The function also strips additional information from the table (such as
notes and shorthand notation) and converts column headings to be written
in a tidy, consistent format (in this case, snake-case with
underscores). The latter ensures it meets BQ requirements for column
headings, which prevents special characters and similar from being used.

The argument required for the function is the data table, that would
have been read into R using the
[`gcp_tables_to_list()`](https://department-for-transport-public.github.io/tinScrape/reference/gcp_tables_to_list.md).

Due to this function being part of the
[`gcp_to_bq()`](https://department-for-transport-public.github.io/tinScrape/reference/gcp_to_bq.md)
function, the arguments stated above do not need to be manually inputted
as this is automated and the input is case insensitive.

The tidying of the data table’s format is done by identifying when the
last qualitative or time period column is. Most of the time, data tables
either has:

- a time period column in the first column which precedes the
  quantitative data,
- columns with qualitative data which precedes the quantitative data, or
- a time period column, qualitative data and then the quantitative data

The location of the first column of quantitative data is identified, and
is then pivoted to the long format desired. This is done using the
[`year_column_check()`](https://department-for-transport-public.github.io/tinScrape/reference/year_column_check.md)
function which is called on as part of the
[`tidied_df()`](https://department-for-transport-public.github.io/tinScrape/reference/tidied_df.md)
function.

The
[`year_column_check()`](https://department-for-transport-public.github.io/tinScrape/reference/year_column_check.md)
function has the following criteria, where all must be met for it to
flag a column containing time period information (that is, year
information):

- is the length of the value 4 characters long?
- is the variable class numeric, double or integer?
- are there no NA values in the column?
- do the first characters of the values start with 19 or 20?

Each pass equates to a value of 1. If the sum of all the checks is 4
(for the number of tests), then the column in question contains time
period data.

The argument required for the function is a column in a dataframe. In
the context of the
[`tidied_df()`](https://department-for-transport-public.github.io/tinScrape/reference/tidied_df.md)
function, this is looped through all columns in a dataframe, so no input
is required for the purposes on TiN.

#### create_bq_table

You can call this function using the following line:

    tinScrape::create_bq_table()

This function exports the tidied data to BQ. It checks if the data table
already exists in BQ so it can truncate/overwrite the data in it. It is
set up this way to ensure the latest information is always reflected in
BQ. Otherwise it will create a new table in the `dft-stats-diss-dev`
dataset in BQ and populate it with the data.

Arguments required are:

- the name of tidied data
- the name of the worksheet, found in the ODS document
- the name of the ODS document

Due to this function being part of the
[`gcp_to_bq()`](https://department-for-transport-public.github.io/tinScrape/reference/gcp_to_bq.md)
function, the arguments stated above do not need to be manually inputted
as this is automated.

### scrape_dynamic_methodology

You can call this function using the following line:

    tinScrape::scrape_dynamic_methodology()

This function webscrapes the any technical notes that accompany a
publication. This covers notes and definitions and background quality
reports. The function calls on other functions that are found in the
utils.R script which are designed to extract hyperlinks that pertain to
statistical outputs only (specifically the
[`collect_collections()`](https://department-for-transport-public.github.io/tinScrape/reference/collect_collections.md)
and
[`collect_links()`](https://department-for-transport-public.github.io/tinScrape/reference/collect_links.md)
functions), and regex-based functions, such as
[`grepl()`](https://rdrr.io/r/base/grep.html), to filter for specific
words that relate to these types of documents.

No argument is required to use this function as the Stats at DfT webpage
is hardcoded into the function in the first instance.

For scraping the ORR technical notes, related to their tables, the
[`scrape_orr_methodology()`](https://department-for-transport-public.github.io/tinScrape/reference/scrape_orr_methodology.md)
function is called.

### scrape_orr_tables

You can call this function using the following line:

    tinScrape::scrape_orr_tables()

This function webscrapes the downloadable hyperlinks for published data
tables from the Office for Rail and Road’s (ORR) data portal, to obtain
rail data published by the organisation. The function calls the
`extract_orr_pages()` function, found in the utils.R script, to extract
hyperlinks that pertain to statistical outputs only.

No argument is required to use this function as the ORR’s passenger rail
usage webpage is hardcoded into the function in the first instance. This
is where the rail data of current interest is hosted on the site.

### utils

This is an R script that contains other functions that contribute to and
complement the running of the aforementioned functions.

#### as.numeric.silent

This function suppresses any warnings when assigning a variable to be
numeric, so it does not appear in the published website.

The argument required is a variable in a dataframe.

#### scrape_links

This function uses the packages `xml2` and `rvest` to extract underlying
data and code behind an HTML webpage. It is currently set up to identify
hyperlinks on a webpage and extracting both the text that is linked, and
the URL destination of the hyperlink.

The argument required is a URL, or webpage.

#### collect_collections

This function uses the
[`scrape_links()`](https://department-for-transport-public.github.io/tinScrape/reference/scrape_links.md)
function above to extract all hyperlinks on a webpage, and then filter
for any mention of “statistics” and “collections” in the URL. The output
is a list of all the statistical collections on the Stats at DfT site.

The argument required is a URL, or webpage.

#### collect_links

This function uses the
[`scrape_links()`](https://department-for-transport-public.github.io/tinScrape/reference/scrape_links.md)
function above to extract all hyperlinks on a webpage, and then filter
for any statistical outputs. It does this by filtering for any mention
of “statistic” or “uploads” in the URL, the former relating more to HTML
documents (such as reports and technical notes) whilst the latter
relates more to downloadable documents (such as Excel tables). The
output is a list of hyperlinks that navigate users to statistical
outputs.

The argument required is a URL, or webpage.

#### scrape_tables

This function uses the
[`scrape_links()`](https://department-for-transport-public.github.io/tinScrape/reference/scrape_links.md)
function above to extract all hyperlinks on a webpage, and then filter
specifically for published, statistical CSV or ODS tables. It does this
by filtering for any mention of “.ods” or “.csv” in the URL. The output
is a list of ODS and CSV tables that are published by statistics teams
in the department.

The argument required is a URL, or webpage.

#### upper_case

This function makes the first character of a string capital.

The argument required is a variable in a dataframe.

#### scrape_method

This function uses the packages `xml2` and `rvest` to extract underlying
data and code behind an HTML webpage, specifically for any mentions of
“information”, “technical” and “guidance” in URLs. These tend to refer
to technical notes that are published alongside a statistical report.
The output is a list of technical notes that are published on the Stats
at DfT website.

The argument required is a URL, or webpage.

#### collect_links

This function uses the packages `xml2` and `rvest` to extract underlying
data and code behind an HTML webpage. It has been designed to search for
and extract URLs from the ORR’s data portal site that relate to
statistical outputs.

The argument required is a URL, or webpage.
