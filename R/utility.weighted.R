
#' Utility defined by weighted function
#'
#' Given estimated toxicity and efficacy probabilities, the utility which is
#' defined by a weighted function is Calculated.
#' @param probt Estimated toxicity probability.
#' @param probe Estimated efficacy probability.
#' @param w1 Weight for toxicity-efficacy trade-off.
#' @param w2 Weight for penalty imposed on toxic doses.
#' @param tox.upper Upper bound of toxicity probability.
#' @return Utility value
#' @export

utility.weighted <- function(probt,probe,w1,w2,tox.upper)
{
  return(probe-w1*probt-w2*probt*(probt>tox.upper))
}

