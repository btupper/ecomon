
#' Show the documentation (aka README) associated with one of the
#'  included datasets.
#'
#' @export
#' @param what charact name of the dataset, currelty only 'zoop'
show_docs <- function(what = 'zoop'){
  ff <- system.file(paste0("README-", what[1]), package = 'ecomon')
  stopifnot(file.exists(ff))
  file.show(ff)
}