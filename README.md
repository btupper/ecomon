### ecomon

R tools for reading and querying [Ecomon](http://www.nefsc.noaa.gov/epd/ocean/MainPage/shelfwide.html) datasets

### Installation

It is easy to install with [devtools](https://cran.r-project.org/web/packages/devtools/index.html)

```R
library(devtools)
install_github("btupper/ecomon")
```

### Read ZOOP data

```R
library(ecomon)
X <- ZoopRefClass$new()
X
```
