globalVariables(c(
  "geometry",
  "PRUID",
  "DAUID_ADIDU",
  "PRUID_PRIDU",
  "PRNAME_PRNOM",
  "CDUID_DRIDU",
  "CDNAME_DRNOM",
  "CDTYPE_DRGENRE",
  "CCSUID_SRUIDU",
  "CCSNAME_SRUNOM",
  "CSDUID_SDRIDU",
  "CSDNAME_SDRNOM",
  "CSDTYPE_SDRGENRE",
  "ERUID_REIDU",
  "ERNAME_RENOM",
  "SACCODE_CSSCODE",
  "SACTYPE_CSSGENRE",
  "CMAUID_RMRIDU",
  "CMAPUID_RMRPIDU",
  "CMANAME_RMRNOM",
  "CMATYPE_RMRGENRE",
  "CTUID_SRIDU",
  "CTNAME_SRNOM",
  "ADAUID_ADAIDU"
))

#' Load OnMarg spatial data
#'
#' This function combines Public Health Ontario's Ontario Marginalization Index data with Statistics Canada's shape files to create an sf_object.  The sf_object can be used for mapping with packages such as ggplot, and for spatial analysis.
#'
#' If a year or level is used that does not exist or is not implemented, an error message will be produced.
#' If the geometry file is unable to be downloaded, an error message will be produced.
#' @param year Integer year of data to load.
#' @param level The level of precision to load, this can be "DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", or "LHIN_SRUID".
#' @param format The format for the geographic object, this can be "sf" or "sp".
#' @param quiet_sf Logical, whether or not to print a message after transforming geometry projection.
#' @return A sf or sp object containing the Marginalization Index and geographic boundaries for every geographic identifier.
#' @import dplyr
#' @import httr
#' @import readxl
#' @import sf
#' @import stringr
#' @import utils
#' @export
#' @examples
#' \dontrun{
#' DA_2016_geo <- om_geo(2016, "DAUID", "sf")
#' }

om_geo <- function(year, level, format, quiet_sf=FALSE) {

  # Initial setup
  year <- toString(year)
  CRS_to_use <- st_crs("+init=EPSG:2962") # NAD83 UTM Zone 17N
  geoLevels <- c("DAUID", "CTUID", "CSDUID", "CCSUID", "CDUID", "CMAUID", "PHUUID", "LHINUID", "LHIN_SRUID")


  # Print warning if requested level does not exist
  if (!level %in% geoLevels) {
    stop(paste0("Level ", level, " is not recognized"))
  }

  # ============================================================================
  # Helper functions
  # ============================================================================

  # Gets the name of a file from its URL
  getFileName <- function(url, extension) {
    str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
      substring(2) %>%
      str_replace(".zip", ".shp")
  }


  # Extracts all geographic files from zip
  extractFromZip <- function(url, quiet_sf) {
    tempDir <- tempdir()
    tempFile <- tempfile()

    filename <- getFileName(url)

    tryCatch(
      download.file(url, tempFile, quiet=TRUE, mode="wb"),
      # Creates an error if the file is unable to download
      error = function(e) stop("Geography file could not be downloaded")
    )

    extensions <- c(".shp", ".dbf", ".prj", ".shx")
    for (extension in extensions) {
      filename <- str_extract(url, "\\/([a-z]|[0-9]|_)+.zip") %>%
        substring(2) %>%
        str_replace(".zip", extension)

      unzip(tempFile, filename, exdir=tempDir)
    }

    filepath <- paste0(tempDir, "/", filename)

    return(st_read(filepath, quiet=quiet_sf))
  }

  # ============================================================================
  # Processing functions
  # ============================================================================

  # Process requests from 2011 and 2016
  process_2011_2016 <- function(year, level, stat_url, quiet_sf) {

    # Gets the page name for the given level and year as "page"
    if (level == "DAUID") {
      prefix <- "DA"
    }
    else {
      prefix <- level
    }

    # Ensures valid page name syntax is used
    if (year == "2011" || level == "DAUID") {
      page <- paste0(prefix, "_", year)
    }
    else {
      page <- paste0(year, "_", prefix)
    }

    # Loads a dataframe containing marginalization data
    df1 <- om_data(year, level)

    # Loads a dataframe containing shape data
    df2 <- extractFromZip(stat_url, quiet_sf) %>%
      st_transform(CRS_to_use) #%>%

    # Summarizes the dataframe if not selecting DAUID
    if (!level == "DAUID") {
      df2 <- df2 %>%
        group_by_at(level) %>%
        summarize(geometry=st_union(geometry))
    }

    # Merges geographic location with ON-Marg values and returns the data frame
    shape_marg <- merge(df2, df1, by=level)

    # Makes a marginalization index column
    shape_marg <- mutate(shape_marg, index={
      shape_marg[,grepl("_Q_", names(shape_marg))] %>%
        st_drop_geometry() %>%
        rowMeans()
    })

    return(shape_marg)
  }



  # Process requests from 2021
  process_2021 <- function(level, url, shp_url, quiet_sf) {

    # =========================
    # Download identifying file
    # =========================

    # Create tempdir and tempfile
    tempDir <- tempdir()
    tempFile <- tempfile()

    # Download the file to tempdir
    tryCatch(
      download.file(url, tempFile, quiet=TRUE, mode="wb"),
      error=function(e) stop("Geography file could not be downloaded")
    )

    # Unzip downloaded file
    unzip(tempFile, "2021_92-151_X.csv", exdir=tempDir)

    # Read in unzipped file as a DF and filter for Ontario
    # Read in unzipped file as a DF and filter for Ontario
    df1 <- read.csv(paste0(tempDir, "\\2021_92-151_X.csv")) %>%
      filter(PRNAME_PRNOM == "Ontario") %>%
      select(
        # Rename columns to make them similar to 2016/2011 data
        DAUID = DAUID_ADIDU,
        PRUID = PRUID_PRIDU,
        PRNAME = PRNAME_PRNOM,
        CDUID	= CDUID_DRIDU,
        CDNAME = CDNAME_DRNOM,
        CDTYPE = CDTYPE_DRGENRE,
        CCSUID = CCSUID_SRUIDU,
        CCSNAME = CCSNAME_SRUNOM,
        CSDUID = CSDUID_SDRIDU,
        CSDNAME = CSDNAME_SDRNOM,
        CSDTYPE = CSDTYPE_SDRGENRE,
        ERUID = ERUID_REIDU,
        ERNAME = ERNAME_RENOM,
        SACCODE = SACCODE_CSSCODE,
        SACTYPE = SACTYPE_CSSGENRE,
        CMAUID = CMAUID_RMRIDU,
        CMAPUID = CMAPUID_RMRPIDU,
        CMANAME = CMANAME_RMRNOM,
        CMATYPE = CMATYPE_RMRGENRE,
        CTUID = CTUID_SRIDU,
        CTNAME = CTNAME_SRNOM,
        ADAUID = ADAUID_ADAIDU
      ) %>%
      unique()

    # =================
    # Download SHP file
    # =================

    df2 <- extractFromZip(shp_url, quiet_sf) %>%
      st_transform(CRS_to_use) %>%
      select(-PRUID)

    df2$DAUID <- as.numeric(df2$DAUID)

    # ===================
    # Format file for use
    # ===================

    # Combine df1$DAUID_ADIDU with df2$DAUID using a left-join
    stats_geom <- right_join(df1, df2, by=c("DAUID"="DAUID")) %>%
      st_as_sf()

    # Summarizes the dataframe if not selecting DAUID
    if (!level == "DAUID") {
      stats_geom <- stats_geom %>%
        group_by_at(level) %>%
        summarize(geometry=st_union(geometry))
    }

    dat_marg <- om_data(2021, level)

    # Merges geographic location with ON-Marg values and returns the data frame
    shape_marg <- merge(stats_geom, dat_marg, by=level)

    # Makes a marginalization index column
    shape_marg <- mutate(shape_marg, index={
      shape_marg[,grepl("_Q_", names(shape_marg))] %>%
        st_drop_geometry() %>%
        rowMeans()
    })

    return(shape_marg)
  }

  # ============================================================================
  # Main switch
  # ============================================================================

  # Process request for a given year
  switch(year,
         # stats_url <- URL for the shapefile
         "2001"={
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000b01a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2006"={
           #stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a06a_e.zip"
           stop("This year has not yet been implemented")
         },
         "2011"={
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gda_000a11a_e.zip"
           shape_marg <- process_2011_2016(2011, level, stat_url, quiet_sf)
         },
         "2016"={
           stat_url <- "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lda_000b16a_e.zip"
           shape_marg <- process_2011_2016(2016, level, stat_url, quiet_sf)
         },
         "2021"={
           stat_url_1 <- "https://www12.statcan.gc.ca/census-recensement/2021/geo/aip-pia/attribute-attribs/files-fichiers/2021_92-151_X.zip"
           stat_url_2 <- "https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lda_000b21a_e.zip"
           shape_marg <- process_2021(level, stat_url_1, stat_url_2, quiet_sf)
         },
         {
           # Breaks if an invalid ON-Marg year is entered
           stop("There is no record for year " + year)
         }
  )

  # Returns the correct format
  switch(format,
         "sf"={
           return(shape_marg)
         },
         "sp"={
           return(as_Spatial(shape_marg))
         },
         {
           stop("Unrecognized file format used, please specify 'sf' or 'sp'")
         }
  )
}
