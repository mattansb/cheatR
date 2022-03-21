context("chtrs")

test_that("chtrs", {
  skip_on_cran()
  skip_if_not(interactive())

  library(cheatR)
  # my_files <- list.files(path = '../../man/files', pattern = '.doc', full.names = TRUE)
  my_files <- list.files(path = 'man/files', pattern = '.doc', full.names = TRUE)
  # my_files

  set.seed(140)
  results <- catch_em(flist = my_files,
                      n_grams = 10, time_lim = 1)

  expect_is(results, "chtrs")
  expect_is(results, "matrix")
  expect_true(all(diag(results) == 1))
  expect_true(all(is.na(results[upper.tri(results)])))
  expect_equal(results[lower.tri(results)],
               c(0.872, 0.901, 0.002, 0.877, 0.002, 0.001),
               tol = .001)

  # plot(results, remove_lonely = F)
  # summary(results)
  # hist(results)
})
