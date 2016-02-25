#' Generate the XML file
#'
#' This takes data.frame of type 'albopop' and export a XML file
#'
#' @param x A dataframe
#' @param rss_title Title of the Feed
#' @param rss_link Link to the source
#' @param rss_file Export file name
#' @param store directory
#' @return A XML file
#' @export
#' @keywords internal

ap_build_rss <- function(x, rss_title, rss_link, rss_file, store = disk()) {

#  if (!any(class(x) %in% "albopop_srs")) {
#    stop("x not of class 'albopop_srs'.",
#         call. = FALSE)
#  }

  x$Inizio    <- Set_Date(x$Inizio)
  x$Fino      <- Set_Date(x$Fino)
  x$timestamp <- x$Inizio

  feed <- xmlTree("rss", attrs=list(version = "2.0"))
  feed$addNode("channel", close=FALSE)
  feed$addNode("title", rss_title)
  feed$addNode("description", paste0(rss_title, " Albo POP RSS"))
  feed$addNode("link", rss_link)
  feed$addNode(newXMLNode("xhtml:meta",
                          namespaceDefinitions = list(xhtml= "http://www.w3.org/1999/xhtml"),
                          attrs = list(name = "robots", content = "noindex")))
  feed$addNode("language", "it")

  for (i in 1:nrow(x)) {

    feed$addNode("item", close = FALSE)
    feed$addNode("title",   x[i, "Oggetto"])
    feed$addNode("pubDate", x[i, "Inizio"])
    feed$addNode("link",    x[i, "link"])
    feed$addNode("guid",    x[i, "link"])
    feed$closeTag()

  }

  feed$closeTag()

  rss <- saveXML(feed, prefix = '<?xml version="1.0" encoding="UTF-8"?>\n')

  #writeLines(rss, con = file.path("feed", rss_file))

  if (!dir.exists(store$path)) dir.create(store$path, recursive = TRUE)
  writeLines(rss, con = file.path(store$path, rss_file))
}

