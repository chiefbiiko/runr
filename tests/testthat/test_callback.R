# callback

testthat::context('callback')

moo <- function() 'moooo'
hoo <- function() list(17L:36L)
callback <- function(err, d) if (is.null(err)) d else stop(err, err$task)

testthat::test_that('callback has either error or data', {
  # without any error callback's return is list
  testthat::expect_type(runSeries(list(moo,
                                       hoo),
                                  callback),
                        'list')
  # check callback data
  testthat::expect_identical(runSeries(list(moo,
                                            hoo),
                                       callback),
                             list(moo='moooo',
                                  hoo=list(17L:36L)))
  # without error error is NULL
  testthat::expect_null(runRace(list(moo, 
                                     hoo),
                                function(err, d) list(err, d))[[1L]])
  # without any error callback's return is named
  testthat::expect_named(runSeries(list(moo,
                                        hoo),
                                   callback),
                         c('moo', 'hoo'))
  # callback must have exactly two parameters (1st class error)
  testthat::expect_error(runRace(list(moo,
                                      hoo),
                                 function(d) d))
  # 2nd class error object always has a $task property
  testthat::expect_type(runParallel(list(moo,  # (2nd class error)
                                         function() stop('color')),
                                    function(err, d) list(err, d))[[1L]]$task,
                        'character')
  # with 1st class error callback throws
  testthat::expect_error(runSeries(list(moo),
                                  callback))
  # with 2nd class error callback throws
  testthat::expect_error(runSeries(list(moo, 
                                        hoo,
                                        function() stop('horror')),
                                   callback))
})