#' Match cheaters
#'
#' @author Mattan S. Ben-Shachar
#' @param ...
#'
#'
#' @return matrix
#' @import purrr
#' @import textreadr
#' @import ngram
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

  # Test
  compare_txt <- function(txt1,txt2) {
    if (is.null(txt1) | is.null(txt1)) {
      return(NULL)
    }
    temp_grams <- ngram(c(txt1,txt2),n = n_grams)
    temp_phrs <- get.phrasetable(temp_grams)
    temp_phrs <- subset(temp_phrs, freq >= 2)
    sum(temp_phrs$prop)
  }

  # pre-alocate
  res <- matrix(NA,
                nrow = length(flist),
                ncol = length(flist))
  diag(res) <- 1
  colnames(res) <- rownames(res) <- flist

  bad_files <- matrix(character(),ncol = 2)

  cat('Looking for cheaters\n')
  pb <- txtProgressBar(min = 0, max = length(flist))
  for (i in seq_along(flist)) {
    for (j in seq_along(flist)) {

      if(is.na(res[j,i])){
        results <- withTimeout(
          {compare_txt(txt_all[i],txt_all[j])},
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
                  bad_files = list(bad_files_to_read,bad_files))
  cat('Busted!')
  return(fin_res)
}
