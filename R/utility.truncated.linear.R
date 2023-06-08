
#' Utility defined by truncated linear function
#'
#' Given estimated toxicity and efficacy probabilities, the utility which is
#' defined by truncated linear functions is Calculated.
#' @usage
#' utility.truncated.linear(probt, probe, tlow, tupp, elow, eupp)
#' @param probt Estimated toxicity probability
#' @param probe Estimated efficacy probability
#' @param tlow Lower threshold of toxicity linear truncated function.
#' @param tupp Upper threshold of toxicity linear truncated function.
#' @param elow Lower threshold of efficacy linear truncated function.
#' @param eupp Upper threshold of efficacy linear truncated function.
#' @return The \code{utility.truncated.linear} returns a utility value defined by
#' the truncated linear functions.
#' @export

utility.truncated.linear <- function(probt,probe,tlow,tupp,elow,eupp)
{
  ld  <- length(probt)
  fpe <- numeric(ld)
  fpt <- numeric(ld)

  for(d in 1:ld){
    if(probe[d]<=elow){
      fpe[d] <- 0
    }else if(probe[d]>=eupp){
      fpe[d] <- 1
    }else{
      fpe[d] <- (probe[d]-elow)/(eupp-elow)
    }
    if(probt[d]<=tlow){
      fpt[d] <- 1
    }else if(probt[d]>=tupp){
      fpt[d] <- 0
    }else{
      fpt[d] <- 1-(probt[d]-tlow)/(tupp-tlow)
    }
  }

  return(fpe*fpt)
}

