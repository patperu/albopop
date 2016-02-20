#' Build Telegram and Twitter feeds
#'
#' This takes data.frame of type 'albopop' and export a XML file
#'
#'
#' @param df A dataframe
#' @return A A dataframe
#' @export
ap_build_msg <- function(df) {

  get_link <- function(item) {

    w <- urlshorteneR::bitly_LinksShorten(longUrl = item$link)

    if(ncol(w) != 0) {
      bly <- w$url
    } else {
      bly <- ""
    }

    item$blyurl       <- bly
    item$msg_Telegram <- paste(item$title, bly, item$pubDate, sep = ", ")
    item$msg_Twitter  <- paste(paste0(substring(item$title, 1, 100), "..."),
                               bly, item$pubDate, sep = ", ")
    return(item)
  }

  res <- list()

  for (i in 1:nrow(df)) {
    res[[i]] <- get_link(df[i, ])
  }

  res <- do.call("rbind", res)
  res
}
