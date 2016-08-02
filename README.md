### ecomon

R tools for reading and querying [Ecomon](http://www.nefsc.noaa.gov/epd/ocean/MainPage/shelfwide.html) version 2.6 datasets.


### Data source

  + Kane J (2007) Zooplankton abundance trends on Georges Bank, 1977-2004. ICES Journal of Marine Science 64(5):909-919											
  + Kane J (2011) Inter-decadal variability of zooplankton abundance in the Middle Atlantic Bight. Journal of Northwest Atlantic Fishery Science 43: 81-92											

### Data prep

Data were downloaded in an multi-tab [Excel](http://office.microsoft.com/en-us/excel) spreadsheet.  Tabs labeled `10m2` and `100m3` were exported as [comma delimited text files](https://en.wikipedia.org/wiki/Comma-separated_values) and [gzipped](http://www.gzip.org/).  These are stored in the package distribution.  The data can be read using a `read_zoop()` function of by using the convenience class `ZoopRefClass` as shown below.


### Requirements

+ [R](https://www.r-project.org/)

+ [sp](https://cran.r-project.org/web/packages/sp/index.html) package

### Installation

It is easy to install with [devtools](https://cran.r-project.org/web/packages/devtools/index.html)

```R
library(devtools)
install_github("btupper/ecomon")
```

### Read ZOOP data

```R

library(ecomon)
X <- Zoop(what = 'm2')   # same as X <- Zoop()
                         # or for volumetric data X <- Zoop(what = 'm3')
X 
# ... lot of stuff printed

# get just salp data within a bounding box
x <- X$get(species = 'salps', bb = c(-75,-60, 35, 38))
str(x)
# 'data.frame':	1189 obs. of  8 variables:
#  $ cruise_name : chr  "AA8704" "AA8704" "AA8704" "AA8704" ...
#  $ station     : int  3 5 11 13 21 22 23 26 27 29 ...
#  $ lat         : num  35.9 36.3 36.6 36.8 37.2 ...
#  $ lon         : num  -74.9 -74.8 -74.9 -74.8 -74.8 ...
#  $ date        : POSIXct, format: "1987-04-13 17:00:00" "1987-04-13 23:15:00" "1987-04-14 11:30:00" ...
#  $ depth       : num  88 360 47 50 68 57 36 41 100 108 ...
#  $ volume_100m3: num  21.9 19.7 87.7 36.2 21.4 ...
#  $ salps       : int  1190 1155 0 842 110 0 0 0 1201 0 ...
 
 
# lighten the load by dropping all but one or more species
X$retain(c("salps","evadnespp"))

# get all the remianing species within a bounding box and within two dates
x <- X$get(bb = c(-75,-60, 35, 38), date_filter = as.POSIXct(c("2008-01-01", "2009-01-01")))
str(x)
# 'data.frame':	21 obs. of  8 variables:
#  $ cruise_name : chr  "AL0801" "AL0801" "AL0801" "DE0808" ...
#  $ station     : int  91 96 97 20 24 25 28 37 38 39 ...
#  $ lat         : num  36.6 36.2 36.1 37.7 37.1 ...
#  $ lon         : num  -74.8 -74.9 -74.7 -74.5 -74.8 ...
#  $ date        : POSIXct, format: "2008-03-22 06:22:00" "2008-03-22 17:27:00" "2008-03-22 19:34:00" ...
#  $ depth       : num  62 45 619 59 63 35 117 227 68 42 ...
#  $ volume_100m3: num  16.8 11.87 2.15 50.11 66.71 ...
#  $ salps       : int  0 0 0 29934 29199 11111 6432 0 0 0 ...

```
