
<!-- README.md is generated from README.Rmd. Please edit that file -->
albopop - Generate RSS feeds

The following functions are implemented:

-   `ap_parse_page`: parse a page
-   `ap_build_rss`: build an rss feed
-   `ap_build_msg`: build a message to send with Telegram and Twitter
-   `ap_send_telegram`: send a message with Telegram

### News

-   Version 0.1.0 released

### Installation

``` r
devtools::install_github("patperu/albopop")
```

### Usage

``` r
library("albopop")
library("rvest")
## Loading required package: xml2

# current version
packageVersion("albopop")
## [1] '0.1.0'
```

The function `ap_parse_page` parse the content for different sites. The parameter `site` specify the type of input. Currently four providers are supported:

-   `JCityGov` [Comune di Medesano](http://195.62.183.230/web/trasparenza/papca-ap/-/papca/igrid/166/177)
-   `mapweb` [Comune di Lovere](http://www.mapweb.it/lovere/albo/albo_pretorio.php)
-   `saga` [Comune di Bellusco](http://pubblicazioni1.saga.it/publishing/AP/index.do?org=bellusco)
-   `studiok` [Comune di Lu](http://albo.studiok.it/lu/albo/)

To parse the announcements for the [Comune di Lu](http://albo.studiok.it/lu/albo/)

``` r
res <- ap_parse_page(url = "http://albo.studiok.it/lu/albo", site = "studiok")
str(res)
## Classes 'albopop_srs' and 'data.frame':  39 obs. of  7 variables:
##  $ APNumero   : chr  "60 / 2016" "59 / 2016" "58 / 2016" "57 / 2016" ...
##  $ Descrizione: chr  "" "" "" "" ...
##  $ Tipo       : chr  "DELIBERA DI GIUNTA" "VARIE COMUNE DI LU" "DELIBERA DI GIUNTA" "DELIBERA DI GIUNTA" ...
##  $ Oggetto    : chr  "[60 / 2016] DELIBERA GIUNTA COMUNALE N. 10 DEL 26/01/2016" "[59 / 2016] CONTRIBUTI REGIONALI PER RACCOLTA, TRASPORTO E SMALTIMENTO DI PICCOLI QUANTITATIVI DI AMIANTO (ETERNIT)" "[58 / 2016] DELIBERA GIUNTA COMUNALE N. 109 DEL 12/11/2015" "[57 / 2016] DELIBERA GIUNTA COMUNALE N. 56 DEL 07/07/2015" ...
##  $ Inizio     : chr  "19/02/2016" "18/02/2016" "18/02/2016" "18/02/2016" ...
##  $ Fino       : chr  "05/03/2016" "24/02/2016" "04/03/2016" "04/03/2016" ...
##  $ link       : chr  "http://albo.studiok.it/lu/albo/dettaglio.php?id=MES00000000602016" "http://albo.studiok.it/lu/albo/dettaglio.php?id=MES00000000592016" "http://albo.studiok.it/lu/albo/dettaglio.php?id=MES00000000582016" "http://albo.studiok.it/lu/albo/dettaglio.php?id=MES00000000572016" ...
```

The function `ap_build_rss` generates an RSS feed and writes a simple XML file in the local default directory `feed`. The input must contain at least three columns named `Oggetto`, `Inizio` and `link`. To write the file "Lu.xml":

``` r
ap_build_rss(res, 
             rss_title = "Comune di Lu", 
             rss_link  = "http://albo.studiok.it/lu/albo", 
             rss_file  = "Lu.xml")
## Warning in xmlRoot.XMLInternalDocument(currentNodes[[1]]): empty XML document
```

### Send notifications with Telegram and Twitter

Before sending notifications it is necessary to set the appropriate Tokens for bit.ly, Telegram and Twitter.

``` r
library(urlshorteneR)

bitly_token <- bitly_auth(key    = Sys.getenv("bitly_key"),
                          secret = Sys.getenv("bitly_secret"))

res <- data.frame(Comune = "Alseno.xml",
                  title  = "[53 / 2016] AVVISO DI AVVENUTO RILASCIO DI...",
                  pubDate = "2016-02-20",
                  link =  "http://albo.studiok.it/alseno/albo/dettaglio.php?id=MES00000000532016",
                  stringsAsFactors = FALSE)

res_msg <- ap_build_msg(res)
str(res_msg)
# 'data.frame': 1 obs. of  7 variables:
# $ Comune      : chr "Alseno.xml"
# $ title       : chr "[53 / 2016] AVVISO DI AVVENUTO RILASCIO DI..."
# $ pubDate     : chr "2016-02-20"
# $ link        : chr "http://albo.studiok.it/alseno/albo/dettaglio.php?id=MES00000000532016"
# $ blyurl      : chr "http://bit.ly/214xeQJ"
# $ msg_Telegram: chr "[53 / 2016] AVVISO DI AVVENUTO RILASCIO DI..., http://bit.ly/214xeQJ"
# $ msg_Twitter : chr "[53 / 2016] AVVISO DI AVVENUTO RILASCIO DI..., http://bit.ly/214xeQJ"
```

The function `ap_build_msg` adds three columns to the input:

-   `blyurl`: The shortened URL
-   `msg_Telegram`: The Telegram message, contains the `title`, the `blyurl` and the `date`
-   `msg_Twitter`: The Twitter message, contains the `title` (truncated to 100 characters), the `blyurl` and the `date`

``` r
ap_send_telegram(res_msg$msg_Telegram, "LU_TOKEN", "LU_CHAT_ID")
```

To send a notification with Twitter

``` r
library('twitteR')

setup_twitter_oauth(Sys.getenv("twitter_api_key"),
                    Sys.getenv("twitter_api_secret"),
                    Sys.getenv("twitter_access_token"),
                    Sys.getenv("twitter_access_token_secret"))

tweet(res_msg$msg_Twitter)
```

### Meta

-   Please [report any issues or bugs](https://github.com/patperu/albopoo/issues).
-   License: MIT

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
