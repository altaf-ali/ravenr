#' Capture Exception
#'
#' \code{capture_exception} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#' @param level set level, warning or error for example
#' @param tags named list of tags
#' @param include_session_info whether to send platform and package list, takes up to 1s or more
#'
#' @export
capture_exception <- function(object, exception, extra, level, tags, include_session_info) {
  UseMethod("capture_exception", object)
}

#' Capture Exception
#'
#' \code{capture_exception.sentry} Captures an exception and sends it to Sentry
#'
#' @param object A Sentry client
#' @param exception exception to catch
#' @param extra set extra context
#' @param level set level, warning or error for example
#' @param tags named list of tags
#' @param include_session_info whether to send platform and package list, takes up to 1s or more
#'
#' @export
capture_exception.sentry <- function(
  object, exception, extra = NULL, level = "error", tags = NULL, include_session_info = TRUE
) {

  required_attributes <- list(
    timestamp = strftime(Sys.time() , "%Y-%m-%dT%H:%M:%S")
  )

  if (include_session_info) {
    required_attributes <- c(required_attributes, get_session_info())
  }

  user <- c(
    object$user,
    list(sysinfo = as.list(Sys.info()))
  )

  tags <- c(
    object$tags,
    tags
  )

  event_id <- generate_event_id()

  exception_context <- list(
    event_id = event_id,
    user = user,
    message = exception$message,
    extra = c(required_attributes, extra),
    tags = tags,
    level = level
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
