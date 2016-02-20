#' Options for saving Albopop feeds.
#'
#' @export
#' @param path Path to store files in. A directory, not a file. Default: \code{feed}
#' @param overwrite (logical) Overwrite an existing file of the same name?
#' Default: \code{TRUE}
disk <- function(path = "feed", overwrite = TRUE){
  wd <- getwd()
  list(store = "disk", path = file.path(wd, path), overwrite = overwrite)
}

#' Convert a Date in 'C' locale.
#'
#' This takes a date character and convert it to a 'C' local date.
#'
#' @param date a date string
#' @return A date
Set_Date <- function(date) {
  lct <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")
  x <- format(lubridate::dmy(date), "%a, %d %b %Y %H:%M:%S")
  Sys.setlocale("LC_TIME", lct)
  x <- paste0(x, " GMT")
  x
}

get_Date <- function(x) {
  lubridate::parse_date_time(x, "%a, %d %b %Y %H:%M:%S", locale = "C")
}

clear_unicode <- function(x) gsub("\u00c2\u00a0 ", "", x)

wrap_nr_ogg <- function(x, ogg) paste0("[", x, "] ", ogg)


.onAttach <- function(...) {

  if (!interactive()) return()
  # borrowed from https://github.com/hrbrmstr/curlconverter/
  packageStartupMessage(paste0("albopop is under development. ",
                               "See https://github.com/patperu/albopop for changes"))

}

