# ravenr
[![Build Status](https://travis-ci.org/jspitzen/ravenr.svg?branch=master)](https://travis-ci.org/jspitzen/ravenr)

A Sentry client for R

## Installation
Install this package directly from GitHub using DevTools:
`devtools::install_github('jspitzen/ravenr')`

## Usage
To send your exceptions to Sentry, you'll need a DSN for your Sentry installation and then set up `ravenr` like this:

```
library(ravenr)
dsn <- '<< your DSN >>'
sentry <- sentry_client(dsn)
tryCatch(non_existing_function(-1), 
         error=function(e) {
           capture_exception(sentry, e)
         })
```

This will report 'Could not find "non_existing function"' to sentry, along with information about the system executing the code and installed packages.

### Customizing tags
To group your error reports better, you can specify tags in your code as follows:

```
sentry <- sentry_client(dsn)
sentry$tags <- list(
  foo='something_else',
  baz='qux'
)
tryCatch(non_existing_function(-1), 
         error=function(e) {
           capture_exception(sentry, e)
         })
```