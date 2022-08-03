library(tidyverse)    # Data cleaning functions
library(readxl)       # Loading data from Excel
library(httr)         # Read data from URL
library(sf)           # Spatial features package to read shape files
library(RColorBrewer) # Colour palettes for the map
library(leaflet)      # Street maps
library(shiny)        # Shiny dashboard


#' Prints 'Hello, world!'
#' @export
hello <- function() {
  print("Hello, world!")
}


#' Loads OnMarg data given a year and level
#' @export
shapeMarg <- function(year, level) {
  year <- toString(year)
  CRS_to_use <- st_crs("+init=EPSG:2962") # NAD83 UTM Zone 17N
  geoLevels <- c("DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", "LHIN_SRUID")
  if (!level %in% geoLevels) {
    stop(paste0("Level ", level, " is not recognized"))
  }
  switch(year,
         # url       <- URL for the marginalization data
         # page      <- Worksheet in the file (CHANGE THIS)
         # format    <- Format of the file
         # stats_url <- URL for the shapefile
         "2001"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2001_updated_May_2012.xls"
           #page <- "da_01"
           #format <- ".xls"
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000b01a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2006"={
           #url <- "http://www.ontariohealthprofiles.ca/onmarg/userguide_data/ON-Marg_2006_updated_May_2012.xls"
           #page <- "da_06"
           #format <- ".xls"
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a06a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2011"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg-2011.xlsx?la=en&sc_lang=en&hash=88EFEB83D1A1DFC5A90517AE2E71C855"
           #page <- "DA_2011"
           format <- ".xlsx"
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a11a_e.zip"
         },
         "2016"={
           url <- "https://www.publichealthontario.ca/-/media/Data-Files/index-on-marg.xls?sc_lang=en"
           #page <- "DA_2016"
           format <- ".xls"
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lda_000b16a_e.zip"
         },
         {
           # Breaks if an invalid ON-Marg year is entered
           stop("There is no record for year " + year)
         }
  )

  if (level == "DAUID") {
    page <- paste0("DA_", year)
  }
  else {
    page <- paste0(year, "_", level)
  }

  print(page)

  # Gets the name of a file from its URL
  getFileName <- function(url, extension) {
    str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
      substring(2) %>%
      str_replace(".zip", ".shp")
  }

  # Extracts all geographic files from zip
  extractFromZip <- function(url) {
    tempDir <- tempdir()
    tempFile <- tempfile()

    filename <- getFileName(url)

    download.file(url, tempFile, quiet=TRUE, mode="wb")

    extensions <- c(".shp", ".dbf", ".prj", ".shx")
    for (extension in extensions) {
      filename <- str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
        substring(2) %>%
        str_replace(".zip", extension)

      unzip(tempFile, filename, exdir=tempDir)
    }

    filepath <- paste0(tempDir, "/", filename)

    return(st_read(filepath))
  }

  # Loads the worksheet into a temporary file (tf)
  GET(url, write_disk(tf <- tempfile(fileext=format)))

  # Dataframe containing marginalization data
  df1 <- read_excel(tf, sheet=page)
  colnames(df1) <- toupper(colnames(df1))

  # Dataframe containing shape data
  df2 <- extractFromZip(stat_url) %>%
    st_transform(CRS_to_use) #%>%
  #select(-CSDNAME, -CSDTYPE, -CTUID, -CTNAME)

  #print(colnames(df1))
  #print(colnames(df2))

  # Merges geographic location with ON-Marg values and returns the data frame
  shape_marg <- merge(df1, df2, by=level) #%>%
  #mutate(index=(Dependency_q_DA16 + Deprivation_q_DA16 + Ethniccon_q_DA16 + Instability_q_DA16)/4)

  return(shape_marg)
}
