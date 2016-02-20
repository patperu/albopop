#' Fetch the data.
#'
#' This scrapes the 'Albo Pretorio' data
#' @param url A URL
#' @param link_url The URL for the links, if NULL same as `url`
#' @param site character, sets the input, currently four sites are supported: "JCityGov", "mapweb", "saga", "studiok"
#' @return A dataframe
#' @export
ap_parse_page <- function(url, link_url = NULL, site = 'studiok') {

# if (is.null(site)) {
#    stop("You have to specify the site.",
#         call. = FALSE)
#  }

 switch(site,
    JCityGov = get_JCityGov(url, link_url),
    mapweb   = get_mapweb(url),
    saga     = get_saga(url),
    studiok  = get_studiok(url, link_url)
    )

}

get_studiok <- function(url, link_url) {

  if (is.null(link_url)) link_url <- url

  x <- lapply(url, function(url) {

    pg <- xml2::read_html(url)

    # Fetch items
    pgt <- pg %>% html_node("#main > table")
    pgt <- html_table(pgt, fill = TRUE)[-c(1:2), ]
    pgt$Importo <- NULL
    names(pgt) <- c("APNumero", "Descrizione", "Tipo", "Oggetto", "Inizio", "Fino")

    pgt$APNumero <- clear_unicode(pgt$APNumero)
    pgt$Oggetto  <- clear_unicode(pgt$Oggetto)
    pgt$Oggetto  <- wrap_nr_ogg(pgt$APNumero, pgt$Oggetto)

    # Fetch links
    link <- pg %>% html_node("tbody")
    link <- html_nodes(link, "tr span a") %>% html_attr("href")
    link <- file.path(link_url, link)
    #link <- data.frame(link = urls, stringsAsFactors = FALSE)

    fin <- data.frame(pgt, link, stringsAsFactors = FALSE)

    # Sort by date
    fin <- fin[order(lubridate::dmy(fin$Inizio), decreasing = TRUE), ]
    rownames(fin) <- NULL
    fin
  })

  fin <- do.call("rbind", x)
  class(fin) <- c("albopop_srs", class(fin))
  fin
}

get_JCityGov <- function(url, link_url) {

  next_page <- function(res) {

    x <- html_nodes(res, "div")
    x <- html_nodes(x, '[class="pagination pagination-centered"]') %>% html_nodes("a")
    idx <- which(x %>% html_text() == "Avanti")
    html_attr(x[idx], "href")

  }

  cn <- c("Anno e Numero Registro", "Tipo Atto",
          "Oggetto", "Periodo Pubblicazioneda - a")

  fin <- list()
  i <- 1
  repeat{

    s <- html_session(url)
    stop_for_status(s)

    res <- content(s$response, encoding = "UTF-8")

    pgt <- html_table(res)[[1]]
    pgt <- pgt[, cn]

    per_pub <- pgt[, 4]

    link <- html_nodes(res, xpath = "//*[@title='Apri Dettaglio']") %>% html_attr("href")

    fin[[i]] <- data.frame(Numero  = pgt[, 1],
                           Tipo    = pgt[, 2],
                           Oggetto = wrap_nr_ogg(pgt[, 1], pgt[, 3]),
                           Inizio  = purrr::flatten_chr(strsplit(per_pub, "  "))[1],
                           Fino    = purrr::flatten_chr(strsplit(per_pub, "  "))[2],
                           link,
                           stringsAsFactors = FALSE)

    # url <- tryCatch(follow_link(s, "Avanti"), error=function(e)(return(NA)))
    # if(is.na(url) || i == 10) break

    url <- next_page(res)
    if(is.null(url) | is.na(url)) break
    i <- i + 1
  }

  fin <- do.call("rbind", fin)
  class(fin) <- c("albopop_srs", class(fin))
  fin

}

get_mapweb <- function(url) {

  base_url <- "http://www.mapweb.it"

  cn <- c("Numero", "Oggetto", "Atto", "Inizio", "Fino")

  next_page <- function(res) {
    x <- html_nodes(res, xpath="//*[@title='Successiva']") %>% html_attr("href")
    x <- paste0(base_url, x)
    x
  }

  fin <- list()
  i <- 1
  repeat{

    pg <- read_html(url)

    pgt <- html_nodes(pg, xpath="//*[@id='pageBox']/div[4]/table") %>% html_table() %>% .[[1]]
    pgt$Oggetto <- wrap_nr_ogg(pgt$Numero, pgt$Oggetto)

    colnames(pgt) <- cn

    link <- html_nodes(pg, xpath="//*[@id='tabella_albo']/tr/td[1]/a") %>% html_attr("href")
    link <- paste0(base_url, link)

    fin[[i]] <- data.frame(pgt, link, stringsAsFactors = FALSE)

    url <- next_page(pg)
    if(identical(base_url, url)) break
    i <- i + 1
  }

  fin <- do.call("rbind", fin)
  class(fin) <- c("albopop_srs", class(fin))
  fin

}


get_saga <- function(url) {

  cn <- c( "N. reg.", "Inizio", "N. atto", "Tipo",  "Oggetto", "Pubblicazione")

  fin <- list()
  i <- 1

  s <- html_session(url)

  repeat{

    z2 <- html_nodes(s, xpath="//*[@id='documentList']") %>% html_table() %>% .[[1]]
    z2 <- z2[, c(1:5,7)]
    colnames(z2) <- cn
    z2$Oggetto <- wrap_nr_ogg(z2[, 1], z2[, "Oggetto"])

    z2$Pubblicazione <- gsub("\\r\\n\t", "", z2$Pubblicazione)
    z2$Pubblicazione <- gsub("\\t", "", z2$Pubblicazione)

    z2$Fino <- strsplit(z2$Pubblicazione, "-") %>%
                        purrr::map(2L) %>%
                        purrr::flatten_chr()
    # autsch
    z2$Fino <- gsub("16", "2016", z2$Fino)

    z2$Pubblicazione <- NULL

    link <- html_nodes(s, xpath="//*[@id='documentList']/tbody/tr/td[8]/a/@href") %>% html_text()
    link <- regmatches(link, regexpr("[0-9]{5}$", link))
    link <- paste0("http://pubblicazioni1.saga.it/publishing/AP/docDetail.do?docId=", link)

    fin[[i]] <- data.frame(z2, link, stringsAsFactors = FALSE)

    s <- tryCatch(follow_link(s, "Successivo"), error=function(e)(return(NULL)))
    if(is.null(s) || i == 20) break
    i <- i + 1

  }

  fin <- do.call("rbind", fin)
  class(fin) <- c("albopop_srs", class(fin))
  fin

}

