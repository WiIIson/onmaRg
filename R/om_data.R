#' Load Public Health Ontario data
#'
#' This is a function for loading the Public Health Ontario OnMarg data into a dataframe
#' @param year Integer year of data to load
#' @param level The level of precision to load, this can be "DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", or "LHIN_SRUID"
#' @examples
#' DA_2016 <- om_phodata(2016, "DAUID")
#' DA_2011 <- om_phodata(2011, "DAUID")
#' CSD_2016 <- om_phodata(2016, "CSDUID")
#' CSD_2011 <- om_phodata(2011, "CSDUID")
#' @import dplyr
#' @import httr
#' @import readxl
#' @import sf
#' @import stringr
#' @import utils
#' @export
om_data <- function(year, level) {
  # Initial setup
  year <- toString(year)
  geoLevels <- c("DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", "LHIN_SRUID")

  # Print warning if requested level does not exist
  if (!level %in% geoLevels) {
    stop(paste0("Level ", level, " is not recognized"))
  }

  # Gets the correct information for a given year
  switch(year,
         # url       <- URL for the marginalization data
         # format    <- Format of the file
         "2001"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2001_updated_May_2012.xls"
           #format <- ".xls"
           stop("This year has not yet been implemented")
         },
         "2006"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2006_updated_May_2012.xls"
           #format <- ".xls"
           stop("This year has not yet been implemented")
         },
         "2011"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg-2011.xlsx?la=en&sc_lang=en&hash=88EFEB83D1A1DFC5A90517AE2E71C855"
           format <- ".xlsx"
         },
         "2016"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg.xls?sc_lang=en"
           format <- ".xls"
         },
         {
           # Breaks if an invalid ON-Marg year is entered
           stop("There is no record for year " + year)
         }
  )

  # Gets the page name for the given level and year as "page"
  if (level == "DAUID") {
    prefix <- "DA"
  }
  else {
    prefix <- level
  }

  if (year == "2011" || level == "DAUID") {
    page <- paste0(prefix, "_", year)
  }
  else {
    page <- paste0(year, "_", prefix)
  }

  # Loads the worksheet into a temporary file (tf)
  GET(url, write_disk(tf <- tempfile(fileext=format)))

  # Loads a dataframe containing marginalization data
  phodata <- read_excel(tf, sheet=page)
  colnames(phodata) <- toupper(colnames(phodata))


  return(phodata)
}
