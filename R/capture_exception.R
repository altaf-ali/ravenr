#' Capture Exception
#'
#' \code{capture_exception} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#'
#' @export
capture_exception <- function(object, exception, extra) {
  UseMethod("capture_exception", object)
}

#' Capture Exception
#'
#' \code{capture_exception.sentry} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#'
#' @export
capture_exception.sentry <- function(object, exception, extra = NULL) {

  session_info <- devtools::session_info()

  platform <- unclass(session_info$platform)

  packages <- session_info$packages
  package_info <- paste0(packages$version, " (", packages$date, ") - ", packages$source)
  packages <- as.list(stats::setNames(package_info, packages$package))

  user <- c(
    object$user,
    list(sysinfo = as.list(Sys.info()))
  )

  required_attributes <- list(
    timestamp = strftime(Sys.time() , "%Y-%m-%dT%H:%M:%S"),
    platform = platform,
    packages = packages
  )

  event_id <- generate_event_id()

  exception_context <- list(
    event_id = event_id,
    user = user,
    message = exception$message,
    exception = list(
      values = list(
        list(
          type = exception$type,
          value = exception$value
        )
      )
    ),
    extra = c(required_attributes, extra),

    tags = list(
      user.name = user$name,
      user.email = user$email,
      event.url = build_event_url(event_id)
    )
  )

  headers <- paste("Sentry", paste(sapply(names(object$auth), function(key) {
    paste0(key, "=", object$auth[[key]])
  }, USE.NAMES = FALSE), collapse = ", "))

  response <- httr::POST(url = object$url,
                         httr::add_headers('X-Sentry-Auth' = headers),
                         encode = "json",
                         body = exception_context)

  return(response)
}

# ---------------------------------------------------------------------
generate_event_id <- function() {
  paste(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
}

# ---------------------------------------------------------------------
build_event_url <- function(event_id) {
  url <- structure(
    list(
      scheme = "https",
      hostname = "altaf-ali.github.io",
      path = file.path("sentry/events", event_id)
    ),
    class = "url"
  )

  httr::build_url(url)
}


