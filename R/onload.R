.onLoad <- function(...){
  if (!require(ngram)) {
    devtools::install_github("wrathematics/ngram")
  }

  packageStartupMessage(
    "Catch 'em cheaters!"
  )
}