data <- data.frame(year = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr1 = c(63, 35, 36, 69, 45, 36),
                   Qtr2 = c(2000, 2001, NA, 2003, 2004, 2005),
                   Qtr3 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr4 = c(1853, 2001, 2002, 2003, 2004, 2005),
                   Qtr5 = c("2000", "2001", "2002", "2003", "2004", "2005"),
                   Qtr6 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr7 = c(2000, 2001, 2002, 2003, 2004, 2005),
                   Qtr8 = c(2000, 2001L, 2002, 2003, 2004, 2005),
                   Qtr9 = c(2000, 2001L, 2002L, 2003, 2004, 2005),
                   Qtr10 = c(2000, 2001, 0002, 2003, 2004, 2005),
                   Qtr11 = c(""),
                   Qtr12 = c("Cars", "Vans", "Buses", "Rail", "Ship", "Air")) %>% 
  transform(Qtr6 = as.integer(Qtr6),
            Qtr7 = as.numeric(Qtr7),
            Qtr8 = as.double(Qtr8))

testthat::test_that("checks on data work", {
  
  testthat::expect_true(year_column_check(data$year))
  testthat::expect_true(year_column_check(data$Qtr6))
  testthat::expect_true(year_column_check(data$Qtr7))
  testthat::expect_true(year_column_check(data$Qtr8))
  testthat::expect_true(year_column_check(data$Qtr9))
  
  testthat::expect_false(year_column_check(data$Qtr1))
  testthat::expect_false(year_column_check(data$Qtr4))
  testthat::expect_false(year_column_check(data$Qtr5))
  testthat::expect_false(year_column_check(data$Qtr10))
  testthat::expect_false(year_column_check(data$Qtr11))
  testthat::expect_false(year_column_check(data$Qtr12))

  testthat::expect_equal(year_column_check(data$Qtr2), NA)
  
})
