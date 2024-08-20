# standard clean dataset
data <- data.frame(
   year = c(2000, 2001, 2002, 2003, 2004, 2005),
   mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
   fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
   Qtr3 = c(82, 43, 54, 57, 46, 32),
   Qtr4 = c(75, 32, 55, 51, 39, 23))

# no year data
data1 <- data.frame(
  mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
   fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
   Qtr3 = c(82, 43, 54, 57, 46, 32),
   Qtr4 = c(75, 32, 55, 51, 39, 23))

# 2 columns that (might) include year data. Code should pivot using the first mention
data2 <- data.frame(
  mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
  year = c(2000, 2001, 2002, 2003, 2004, 2005),
  fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
  Qtr3 = c(82, 43, 54, 57, 46, 32),
  Qtr4 = c(2007, 2008, 2009, 2010, 2011, 2012))

# contextual information, and use of GSS notation, in dataset
data3 <- data.frame(
  `mode!` = c("Cars [note 1]", "Vans or LGVs", "Taxis [note 2]", "Rail", "Air", "Sea"),
    year = c(2000, 2001, 2002, 2003, 2004, 2005),
    `fuel [note 3]`= c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
    `Qtr3*` = c(82, "No data", 54, "[x]", 46, 32),
    Qtr4 = c(2007, 2008, 2009, 2010, 2011, 2012))


test_that("tidy function doesn't give an error with expected format", {
  expect_no_error(tidied_df(data))
  expect_no_error(tidied_df(data1))
  expect_no_error(tidied_df(data2))

})

test_that("tidy function returns data in the expected shape", {
  expect_equal(nrow(tidied_df(data)), 12)
  expect_equal(ncol(tidied_df(data)), 6)
  expect_equal(nrow(tidied_df(data1)), 12)
  expect_equal(ncol(tidied_df(data1)), 5)
  expect_equal(nrow(tidied_df(data2)), 6)
  expect_equal(ncol(tidied_df(data2)), 7)

})


test_that("tidy function does not work with a dataset in the format expected", {
  expect_error(tidied_df(data3), "No columns in correct format for tidying.
        Please ensure there is at least one numeric column which does not contain a year value")

})
