runr
================

`runr` packs a set of higher order functions for running lists of functions in various modes.

:movie\_camera: *[runSeries](#runseries)*

:ocean: *[runWaterfall](#runwaterfall)*

:running: *[runRace](#runrace)*

:100: *[runParallel](#runparallel)*

------------------------------------------------------------------------

Get it
------

``` r
devtools::install_github('chiefBiiko/runr')
```

------------------------------------------------------------------------

API
---

`runr::run*(tasks = list(NULL), cb = NULL)`

-   `tasks` List of functions **required**
-   `cb` Callback with signature `cb(error, data)` **optional**

Values for the `tasks` or `cb` parameter can be defined anonymous or referenced to via a valid function name. If a callback is defined it will always have exactly one non-`NULL` argument only. Without errors during task execution the `data` argument of the callback is a named list. In case of errors during task execution the `error` argument of the callback is an ordinary error object with *one* additional property `$task` which indicates the function that threw.

``` r
# callback skeleton - must have exactly two parameters
callback <- function(err, data) {
  if (!is.null(err)) stop(err, err$task)
  data
}
```

[`bounds`](https://github.com/chiefBiiko/bounds), a dependency of `runr`, has an export `bounds::bind` that allows binding parameters to functions. It takes a function and a variable sequence of parameters as inputs and returns a closure with the given parameters bound to it. Might come in handy at times.

------------------------------------------------------------------------

runSeries
---------

`runr::runSeries` runs its input tasks sequentially returning either a named list (on error `NULL`) or the value of a given callback.

``` r
# some named functions
moo <- function() 'moooo'
zoo <- function() 1L:3L

# run as series
runr::runSeries(list(Sys.getpid, zoo, moo), callback)
```

    $Sys.getpid
    [1] 6684

    $zoo
    [1] 1 2 3

    $moo
    [1] "moooo"

------------------------------------------------------------------------

runWaterfall
------------

`runr::runWaterfall` runs its input tasks sequentially, passing each task's return value to the next task, and returns either a named list (on error `NULL`) or the value of a given callback.

:ocean: All tasks except the first must have at least one parameter.

``` r
# chain/pipe consecutive returns
runr::runWaterfall(list(zoo,
                        base::factorial,
                        bounds::bind(Reduce, function(a, b) a + b)),
                   callback)
```

    $function1
    [1] 1 2 3

    $function2
    [1] 1 2 6

    $function3
    [1] 9

------------------------------------------------------------------------

runRace
-------

`runr::runRace` runs its input tasks parallel until the very first return of any of its tasks and returns either a named list (all `NULL` but one and on error `NULL`) or the value of a given callback.

``` r
# run a race
runr::runRace(list(bounds::bind(utils::download.file, 
                                'http://www.textfiles.com/etext/AUTHORS/TWAIN/huck_finn',
                                'huck_finn.txt'), 
                   bounds::bind(utils::download.file, 
                                'http://contentserver.adobe.com/store/books/HuckFinn.pdf',
                                'huck_finn.pdf')), 
              callback)
```

    $function1
    NULL

    $function2
    [1] 0

------------------------------------------------------------------------

runParallel
-----------

`runr::runParallel` runs its input tasks parallel until all complete and returns either a named list (on error `NULL`) or the value of a given callback.

``` r
# callback
hireme <- function(err, data) {
  if (!is.null(err)) stop(err, err$task)  # check n go
  sprintf('dev: @%s | %s: %s | <%s',
          data$function1$login,
          hi <- grep('hi', names(data$function1), value=TRUE),
          as.character(data$function1[[hi]]), 
          data$function2)
}

# see ya!
runr::runParallel(list(bounds::bind(jsonlite::fromJSON, 
                                    'https://api.github.com/users/chiefBiiko'), 
                       bounds::bind(base::sub, 
                                    '^.*(3).*$', 
                                    '\\1', 
                                    paste0(installed.packages(), collapse=''))), 
                  hireme)
```

    [1] "dev: @chiefBiiko | hireable: TRUE | <3"
