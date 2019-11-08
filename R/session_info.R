get_session_info <- function() {
  session_info <- devtools::session_info()

  platform <- unclass(session_info$platform)

  packages <- session_info$packages
  package_info <- paste0(packages$version, " (", packages$date, ") - ", packages$source)
  packages <- as.list(stats::setNames(package_info, packages$package))
  return(list("platform" = platform, "packages" = packages))
}