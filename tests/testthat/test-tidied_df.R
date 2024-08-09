# standard clean dataset
data <- list(year = c(2000, 2001, 2002, 2003, 2004, 2005),
             mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
             fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
             Qtr3 = c(82, 43, 54, 57, 46, 32),
             Qtr4 = c(75, 32, 55, 51, 39, 23))

# no year data
data1 <- list(mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
             fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
             Qtr3 = c(82, 43, 54, 57, 46, 32),
             Qtr4 = c(75, 32, 55, 51, 39, 23))

# 2 columns that (might) include year data. Code should pivot using the first mention
data2 <- list(mode = c("Cars", "Vans", "Taxis", "Rail", "Air", "Sea"),
              year = c(2000, 2001, 2002, 2003, 2004, 2005),
              fuel = c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
              Qtr3 = c(82, 43, 54, 57, 46, 32),
              Qtr4 = c(2007, 2008, 2009, 2010, 2011, 2012))

# contextual information, and use of GSS notation, in dataset
data3 <- list(`mode!` = c("Cars [note 1]", "Vans or LGVs", "Taxis [note 2]", "Rail", "Air", "Sea"),
              year = c(2000, 2001, 2002, 2003, 2004, 2005),
              `fuel [note 3]`= c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel", "Petrol"),
              `Qtr3*` = c(82, "No data", 54, "[x]", 46, 32),
              Qtr4 = c(2007, 2008, 2009, 2010, 2011, 2012))

# missing information from column
data4 <- list(`mode!` = c("Cars [note 1]", "Vans or LGVs", "Taxis [note 2]", "Rail", "Air", "Sea"),
              year = c(2000, 2001, 2002, 2003, 2004, 2005),
              `fuel [note 3]`= c("Diesel", "Petrol", "Diesel", "Petrol", "Diesel"),
              `Qtr3*` = c(82, "No data", 54, 57, 46, 32),
              Qtr4 = c("[x]", 2008, 2009, 2010, 2011, 2012))


test_that("tidy function works with a dataset in the format expected", {
  expect_no_error(tidied_df(data))
  expect_no_error(tidied_df(data1))
  expect_no_error(tidied_df(data2))
  expect_no_error(tidied_df(data3))
  
})


test_that("tidy function does not work with a dataset in the format expected", {
  expect_error(tidied_df(data4))
  
})
