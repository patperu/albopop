% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ap_build_rss.R
\name{ap_build_rss}
\alias{ap_build_rss}
\title{Generate the XML file}
\usage{
ap_build_rss(x, rss_title, rss_link, rss_file, store = disk())
}
\arguments{
\item{x}{A dataframe}

\item{rss_title}{Title of the Feed}

\item{rss_link}{Link to the source}

\item{rss_file}{Export file name}

\item{store}{directory}
}
\value{
A XML file
}
\description{
This takes data.frame of type 'albopop' and export a XML file
}
\keyword{internal}

