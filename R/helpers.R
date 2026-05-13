fix_call <- function(
  object,
  env_for_call
) {
  # Evaluate all the arguments and
  # set the call with the values
  call0 <- stats::getCall(object)
  tmp <- lapply(
            call0,
            \(x, envir0) eval(x, envir0),
            envir0 = env_for_call
          )
  tmp <- as.call(tmp)
  tmp[[1]] <- call0[[1]]
  object@call <- tmp
  object
}