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
X <- Zoop()
X

# get just salp data within a bounding box
x <- X$get(species = 'salps', bb = c(-75,-60, 35, 38))
```
