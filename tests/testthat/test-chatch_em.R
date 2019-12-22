context("chtrs")

test_that("chtrs", {
  library(cheatR)
  my_files <- list.files(path = '../../doc', pattern = '.doc', full.names = T)
  my_files

  set.seed(140)
  results <- catch_em(flist = my_files,
                      n_grams = 10, time_lim = 1)

  testthat::expect_is(results, "chtrs")
  testthat::expect_is(results, "matrix")
  testthat::expect_true(all(diag(results) == 1))
  testthat::expect_true(all(is.na(results[upper.tri(results)])))
  testthat::expect_equal(results[lower.tri(results)],
                         c(0.873, 0.901, 0.002, 0.878, 0.002, 0.002),
                         tol = .001)
})
