#' Match cheaters
#'
#' @author Mattan S. Ben-Shachar
#' @param flist a list of documents (\code{.doc}/\code{.docx}/\code{.pdf}). A full/relative path must be provided.
#' @param n_grams see \code{\link{ngram}} package.
#' @param time_lim max time in seconds for each comparison. Defult is 1 second, had no problem comparing documents with 50K words.
#'
#'
#' @return \item{results}{A correlation-like matrix with each cell indicating the match (0-1) between two of the documents.} \item{bad_files}{\itemize{
##'  \item{bad_read}{ vector of documents that could not be read.}
##'  \item{bad_ngrams}{ matrix of pair-wise comparisons that could not be compared.}
##' }}
#' @import purrr
#' @import utils
#' @importFrom R.utils withTimeout
#' @export
catch_em <- function(flist, n_grams = 10, time_lim = 1L){

  # load txt and mark bad files
  cat('Reading documents...')
  safe_read <- safely(read_document)
  txt_all <- map(flist,~safe_read(.x,combine = T)$result)
  txt_all <- flatten_chr(map_if(txt_all,is_empty, ~ NA_character_))
  bad_files_to_read <- flist[is.na(txt_all)]
  flist <- flist[!is.na(txt_all)]
  txt_all <- txt_all[!is.na(txt_all)]
  cat(' Done!\n')

  # pre-alocate
  res <- matrix(NA,
                nrow = length(flist),
                ncol = length(flist))
  diag(res) <- 1
  colnames(res) <- rownames(res) <- basename(flist)

  bad_files <- matrix(character(),ncol = 2)

  cat('Looking for cheaters\n')
  pb <- txtProgressBar(min = 0, max = max(c(length(flist),1)))
  for (i in seq_along(flist)) {
    for (j in seq_along(flist)) {

      if(is.na(res[j,i])){
        results <- withTimeout(
          {compare_txt(txt_all[i],txt_all[j], n_grams = n_grams)},
          timeout = time_lim,
          onTimeout = "silent"
        )
        if (is.null(results)){
          bad_files <- rbind(
            bad_files,
            c(flist[i],flist[j])
          )
        }
        res[j,i] <- res[i,j] <- results
      }

      # progbar
      setTxtProgressBar(pb, i)
    }
  }

  res[upper.tri(res)] <- NA

  fin_res <- list(results = res,
                  bad_files = list(bad_read = bad_files_to_read,bad_ngrams = bad_files))
  class(fin_res) <- c('chtrs','list')
  cat('\nBusted!\n')
  return(fin_res)
}

#' Match cheaters
#'
#' @author Mattan S. Ben-Shachar
#' @param txt1 a char vector of length 1 to compare to `txt2`
#' @param txt2 a char vector of length 1 to compare to `txt1`
#' @param n_grams see \code{\link{ngram}} package.
#'
#'
#' @return The percent (0-1) of overlap between the texts
#'
#' @import purrr
#' @import textreadr
#' @import ngram
#' @importFrom dplyr inner_join
compare_txt <- function(txt1,txt2, n_grams = 10) {
  if (is.null(txt1) | is.null(txt2)) {
    return(NULL)
  }

  total_freq <- function(x){
    x$tot <- sum(x$freq)
    return(x)
  }

  txts <- list(txt1,txt2)
  temp_grams <- map(txts, ngram, n = n_grams)
  temp_phrs <- map(temp_grams, get.phrasetable)
  temp_phrs <- map(temp_phrs, total_freq)
  XX <- inner_join(temp_phrs[[1]],temp_phrs[[2]], by = 'ngrams')
  XX$freq <- 2*apply(cbind(XX$freq.x,XX$freq.y),1,min)
  sum(XX$freq)/(XX$tot.x[1] + XX$tot.y[1])
}
