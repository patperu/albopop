#' @title Read 'Albo Pretorio' pages and build a RSS-Feed
#'
#' @description Provides functions to read 'Albo Pretorio' pages and export a RSS-Feed
#'
#' @name albopop-package
#' @docType package
#' @author Patrick Hausmann \email{patrick.hausmann@@covimo.de}
#' @importFrom httr GET content stop_for_status write_disk
#' @importFrom rvest html_attr html_table html_nodes html_session
#'              html_text follow_link html_node
#' @importFrom lubridate parse_date_time ymd dmy
#' @importFrom purrr flatten_chr map_chr
#' @importFrom stringr str_replace
#' @importFrom XML xmlTree addNode saveXML xpathSApply
#'                 xmlRoot xmlParse xmlValue xmlTreeParse newXMLNode
#' @importFrom xml2 read_html
NULL

#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL
