#' Match cheaters
#'
#' @author Mattan S. Ben-Shachar
#' @param flist a list of documents (`.doc`/`.docx`/`.pdf`). A full/relative
#'   path must be provided.
#' @param n_grams see [`ngram`] package.
#' @param time_lim max time in seconds for each comparison. Defult is 1 second,
#'   had no problem comparing documents with 50K words.
#' @param progress_bar Should a progress bar be printed to the console?
#'
#' @return A correlation matrix of class `chtrs` with each cell indicating the match (0-1) between two of the documents.
#'
#' @examples
#' if (interactive()) {
#'   files <- choose.files()
#'   catch_em(files)
#' }
#'
#' @import purrr
#' @importFrom utils txtProgressBar
#' @importFrom utils setTxtProgressBar
#' @importFrom R.utils withTimeout
#' @importFrom textreadr read_document
#' @export
catch_em <- function(flist, n_grams = 10, time_lim = 1L, progress_bar = TRUE){
  if (isTRUE(length(flist) < 2)) {
    stop("Must specify at least 2 files.")
  }

  # load txt and mark bad files
  message('Reading documents...')
  safe_read <- safely(textreadr::read_document)
  txt_all <- map(flist,  ~ safe_read(.x, combine = TRUE)$result)
  txt_all <- flatten_chr(map_if(txt_all, is_empty, ~ NA_character_))
  bad_files_to_read <- flist[is.na(txt_all)]
  flist <- flist[!is.na(txt_all)]
  txt_all <- txt_all[!is.na(txt_all)]

  if (isTRUE(length(txt_all)==0)) {
    stop("Couldn't read any files:\n", paste0(bad_files_to_read, collapse = ",\t"),
         call. = FALSE)
  }
  message('\b Done!')

  # pre-alocate
  res <- matrix(NA,
                nrow = length(flist),
                ncol = length(flist))
  diag(res) <- 1
  colnames(res) <- rownames(res) <- basename(flist)

  bad_files <- matrix(character(), ncol = 2)

  message('Looking for cheaters...')
  if(isTRUE(progress_bar)) pb <- utils::txtProgressBar(min = 0, max = max(c(length(flist), 1)))
  for (i in seq_along(flist)) {
    for (j in seq_along(flist)) {
      if (isTRUE(is.na(res[j, i]))) {
        results <- R.utils::withTimeout({
          compare_txt(txt_all[i], txt_all[j], n_grams = n_grams)
        },
        timeout = time_lim,
        onTimeout = "silent")
        if (isTRUE(is.null(results))) {
          bad_files <- rbind(bad_files,
                             c(flist[i], flist[j]))
        }
        res[j, i] <- res[i, j] <- results
      }

      # progbar
      if(isTRUE(progress_bar)) utils::setTxtProgressBar(pb, i)
    }
  }

  res[upper.tri(res)] <- NA

  attributes(res) <- c(attributes(res), bad_read = bad_files_to_read, bad_ngrams = bad_files)
  class(res) <- c('chtrs', class(res))
  message('\nBusted!')
  return(res)
}

#' Match cheaters
#'
#' @author Mattan S. Ben-Shachar
#' @param txt1,txt2 character vectors to compare, each of length 1.
#' @param n_grams see [ngram] package.
#' @param across How should the percentage of overlap be computed?
#'
#' @return The percent (0-1) of overlap between the texts
#'
#' @examples
#' text1 <- "My horse is large and white, and I ride it every day."
#' text2 <- "My mule is large and brown, and I ride it most days."
#' compare_txt(text1, text2, n_grams = 3)
#'
#' @import purrr
#' @importFrom ngram ngram
#' @importFrom ngram get.phrasetable
#' @export
compare_txt <- function(txt1,txt2, n_grams = 10,
                        across = c("both","txt1","txt2")) {
  across <- match.arg(across)

  if (isTRUE(is.null(txt1)) || isTRUE(is.null(txt2))) {
    return(NULL)
  }

  total_freq <- function(x) {
    x$tot <- sum(x$freq)
    return(x)
  }

  txts <- list(txt1, txt2)
  temp_grams <- map(txts, ngram::ngram, n = n_grams)
  temp_phrs <- map(temp_grams, ngram::get.phrasetable)
  temp_phrs <- map(temp_phrs, total_freq)
  XX <- merge(temp_phrs[[1]], temp_phrs[[2]], by = 'ngrams')
  if (isTRUE(nrow(XX) == 0)) return(0)
  XX$freq <- 2 * pmin(XX$freq.x, XX$freq.y, na.rm = TRUE)

  switch (across,
    both = sum(XX$freq) / (XX$tot.x[1] + XX$tot.y[1]),
    txt1 = sum(XX$freq.x) / XX$tot.x[1],
    txt2 = sum(XX$freq.y) / XX$tot.y[1]
  )
}
