data <- data.frame(Qtr1 = c(63, 35, 36, 69, 45, 36),
                   Qtr2 = c(2000, 2001, NA, 2003, 2004, 2005),
                   Qtr3 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr4 = c(1853, 2001, 2002, 2003, 2004, 2005),
                   Qtr5 = c("2000", "2001", "2002", "2003", "2004", "2005"),
                   Qtr6 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr7 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr8 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr9 = c(2000, 2001, 0002, 2003, 2004, 2005),
                   Qtr10 = c(""),
                   Qtr11 = c("Cars", "Vans", "Buses", "Rail", "Ship", "Air"),
                   Qtr12 = c("Cars", NA, "Buses", "Rail", "Ship", "Air")) %>%
  transform(Qtr6 = as.integer(Qtr6),
            Qtr7 = as.numeric(Qtr7),
            Qtr8 = as.double(Qtr8))

testthat::test_that("year check works on 4 character numerics", {

  testthat::expect_true(year_column_check(data$Qtr3))

})

testthat::test_that("year check fails on 2 character numerics", {

  testthat::expect_false(year_column_check(data$Qtr1))

})

testthat::test_that("year check fails on column containing NA values", {

  testthat::expect_false(year_column_check(data$Qtr2))

})


testthat::test_that("year checks fail on data before 1900", {

  testthat::expect_false(year_column_check(data$Qtr4))
  testthat::expect_true(year_column_check(data$Qtr9))

})


testthat::test_that("year checks fail on character values", {

  testthat::expect_false(year_column_check(data$Qtr5))
  testthat::expect_false(year_column_check(data$Qtr10))
  testthat::expect_false(year_column_check(data$Qtr11))
  testthat::expect_false(year_column_check(data$Qtr12))

})


testthat::test_that("year checks work on different numeric column types", {

  testthat::expect_true(year_column_check(data$Qtr6))
  testthat::expect_true(year_column_check(data$Qtr7))
  testthat::expect_true(year_column_check(data$Qtr8))

})
