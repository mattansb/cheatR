
<!-- README.md is generated from README.Rmd. Please edit that file -->
cheatR: Catch 'em baddies <img src="doc\cheatRball.png" align="right" height="345" width="300"/>
================================================================================================

This is a mini package to help you find cheaters by comparing hand-ins.

Download and Install
--------------------

You can install `cheatR` from [github](https://github.com/mattansb/cheatR) with:

``` r
# install.packages("devtools")
devtools::install_github("mattansb/cheatR")
```

Example use
-----------

Create a list of files:

``` r
my_files <- list.files(path = 'doc', pattern = '.doc', full.names = T)
my_files
```

    ## [1] "doc/sample (1).docx" "doc/sample (2).docx" "doc/sample (4).docx"
    ## [4] "doc/sample (5).doc"

The first 3 files are different drafts of the same paper, so we would expect them to be similar to each other, and the last is a draft of a different paper, so it should be dissimilar to the first 3.

Then use `cheatR` to fix duplicates.

``` r
library(cheatR)
```

    ## Loading required package: ngram

    ## Catch 'em cheaters!

``` r
results <- catch_em(flist = my_files,
                    n_grams = 10, time_lim = 1) # defults
```

    ## Reading documents... Done!
    ## Looking for cheaters
    ## ===========================================================================Busted!

The input values are:

-   `flist` - a list of documents (`.doc`/`.docx`/`.pdf`)
-   `n_grams` - see [`ngram` package](https://github.com/wrathematics/ngram).
-   `time_lim` - max time in seconds for each comparison (we found that some corrupt files run forever and crash R, so a time limit might be needed).

The resulting list contains a matrix with the similarity values between each pair of documents:

``` r
knitr::kable(results$results)
```

|                     |  doc/sample (1).docx|  doc/sample (2).docx|  doc/sample (4).docx|  doc/sample (5).doc|
|---------------------|--------------------:|--------------------:|--------------------:|-------------------:|
| doc/sample (1).docx |            1.0000000|                   NA|                   NA|                  NA|
| doc/sample (2).docx |            0.8982618|            1.0000000|                   NA|                  NA|
| doc/sample (4).docx |            0.8763864|            0.9310377|            1.0000000|                  NA|
| doc/sample (5).doc  |            0.0684318|            0.0910398|            0.0647664|                   1|

Authors
-------

-   **Mattan S. Ben-Shachar** \[aut, cre\].
-   **Almog Simchon** \[aut\].
