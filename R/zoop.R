# zoop.R



#' Retrieve the Zoo-Ichy data version
#'
#' @export
#' @return character version identifier
zoop_version <- function() {return("2_6")}

#' Read the Zoo-Ichy Plankton data sheet.
#'
#' @export
#' @param what character, either 'm2' or 'm3', ignored if \code{filename} is not 
#'    \code{NULL}
#' @param filename character or NULL.  If NULL then the package's data is read.
#'   if not NULL then the specified file is read.
#' @return a data.frame or NULL
read_zoop <- function(what = c("m2", "m3")[2], filename = NULL){
   
   if (is.null(filename)){
      
      fini <- sprintf("_v%s.csv.gz", zoop_version())
      filename <- file.path(system.file(package = 'ecomon'),
         switch(tolower(what[1]),
            'm2' = paste0('EcoMon_Zooplankton_Data_m2', fini),
            'm3' = paste0('EcoMon_Zooplankton_Data_m3', fini),
            stop("what is not known:", what[1])))
   }
   
   x <- try(read.csv(filename[1], stringsAsFactors = FALSE))
   if (inherits(x,'try-error')) {
      cat("error reading file:", filename[1])
      return(NULL)
   }
   
   # fix issues with depth
   x[,'depth'] <- as.numeric(gsub(",", "", x[,'depth']))
   
   # replace date and time with POSIXct
   dt <- as.POSIXct(paste(x[,'date'], paste0(x[,'time'],":00")),
         format = "%d-%b-%Y %H:%M:%S", tz = "UTC")
   x[,'date'] <- dt   # replace
   x[,'time'] <- NULL # remove 
   
   invisible(x)
}

######### functions above
######### class and methods below

#' A simple container class for the Zoop data set.
#'
#' @export
#' @field version character, the data version if known
#' @field data a data.frame or NULL
ZoopRefClass <- setRefClass("ZoopRefClass",
   fields = list(
      version = 'character',
      data = 'ANY'),
   methods = list(
      initialize = function(...){
         .self$version = zoop_version()
         .self$data = ecomon::read_zoop(...)
         },
      show = function(){
         cat("Reference object of class",classLabel(class(.self)), "\n")
         cat("Ecomon version:", .self$version, "\n")
         print(summary(.self$data))
      })
   )

#' Retain one or more columns - others are removed
#' 
#' @name ZoopRefClass_retain
#' @param name character vector of one or more columns to retain
ZoopRefClass$methods(
   retain = function(name = 'salps'){
      nm <- names(.self$data)
      ix <- grep("volume_", nm, fixed = TRUE)

      keep <- nm %in% name
      keep[1:ix] <- TRUE
      .self$data <- .self$data[,keep]
      invisible(NULL)
   })

#' Get one or more records
#'
#' @name ZoopRefClass_get
#'
#' @param species  character one or more species names to retrieve or 'all'
#'  NOTE: if you try c("salps", "all") you will get "all"
#' @param date_filter POSIXct or Date, two element vector populated according to
#'    By default NULL.  Records within the date_filter[1] <=  >= date_filter[2]
#'    are returned. 
#' @param projargs character, by default "+proj=longlat +datum=WGS84"
#' @param form character either 'data.frame' or 'SpatialPointsDataFrame' 
#' @param bb a 4 element vector of [xmin, xmax, ymin, ymax] or NULL bounding box.  
#'    Data are clipped to this bbox.
#' @return data.frame, SpatialPointsDataFrame or NULL invisibly
ZoopRefClass$methods(
   get = function(
      species = c("salps", "all")[1],
      form = c("data.frame", "SpatialPointsDataFrame")[1],
      projargs = "+proj=longlat +datum=WGS84",
      bb = NULL,
      date_filter = NULL){
      
      if (is.null(.self$data)) {
         cat("Data field is not populated\n")
         return(NULL)
      }
      x <- .self$data
      # note that the caller could do c("salps", "all") in which case we return
      # "all"
      spc <- tolower(species)
      if (!any(spc == "all")) {
         if (!all(spc %in% names(x))){
            stop("please check species names:", paste(spc, collapse = " ") )
         }
         # these are the metadata columns ("cruisename" through "volume_")
         meta <- seq_len(which(grepl("volume_", names(x), fixed = TRUE)))
         x <- x[,c(names(x)[meta], spc)]
      }
      
      if (nrow(x) == 0) return(NULL)
      
      if (!is.null(bb)){
         if (length(bb) != 4) stop("bb must have 4 elements")
         ix <- (x[,'lon'] >= bb[1]) & 
               (x[,'lon'] <= bb[2]) & 
               (x[,'lat'] >= bb[3]) & 
               (x[,'lat'] <= bb[4])
         x <- x[ix,]
      }
   
      if (nrow(x) == 0) return(NULL)
      
      if (!is.null(date_filter)){
         if (!inherits(date_filter, 'POSIXct') || (length(date_filter) < 2)){
            stop("date_filter must be two element vector of class POSIXct")
         }
         ix <- findInterval(x[,'date'], sort(date_filter))
         x <- x[ix==1,]
      }
 
      if (tolower(form[1]) == "spatialpointsdataframe"){
         sp::coordinates(x) <- ~lon+lat
         sp::proj4string(x) <- projargs
      }
     
      invisible(x)  
   })


#' Create an instance of a ZoopRefClass object
#'
#' @export
#' @param ... further arguments for \code{\link{read_zoop}}
#' @return an instance of ZoopRefClass
Zoop <- function(...){
   getRefClass("ZoopRefClass")$new(...)
}
   