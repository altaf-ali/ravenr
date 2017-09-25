#' Create Sentry Client
#'
#' \code{sentry_client} Creates a sentry client
#'
#' @param dsn set Data Source Name
#' @param user set user context
#' @param version protocol version
#'
#' @export
sentry_client <- function(dsn, user = NULL, version = NULL) {
  if (is.null(version))
    version <- 7

  url <- httr::parse_url(dsn)

  client <- structure(
    list(
      dsn = dsn,
      auth = list(
        sentry_version = version,
        sentry_client = paste("ravenr", getNamespaceVersion("ravenr"), sep="/"),
        sentry_timestamp = as.integer(Sys.time()),
        sentry_key = url$username,
        sentry_secret = url$password
      )
    ),
    class = "sentry"
  )

  if (!is.null(user))
    client$user <- user

  url$username <- NULL
  url$password <- NULL
  url$path <- file.path("api", url$path, "store/")

  client$url <- httr::build_url(url)

  return(client)
}
