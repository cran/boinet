
#' Utility defined by scoring
#'
#' Given estimated toxicity and efficacy probabilities, the utility which is
#' defined by scoring is calculated.
#' @usage
#' utility.scoring(probt, probe, psi00, psi11)
#' @param probt Estimated toxicity probability.
#' @param probe Estimated efficacy probability.
#' @param psi00 Score for toxicity=no and efficacy=no.
#' @param psi11 Score for toxicity=yes and efficacy=yes.
#' @return The \code{utility.scoring} returns a utility value defined by the scoring.
#' @export

utility.scoring <- function(probt,probe,psi00,psi11)
{
  psi.e0t1 <- 0
  psi.e0t0 <- psi00
  psi.e1t1 <- psi11
  psi.e1t0 <- 100

  ut = (  psi.e0t1*(1-probe)*probt
        + psi.e0t0*(1-probe)*(1-probt)
        + psi.e1t1*probe    *probt
        + psi.e1t0*probe    *(1-probt))

  return(ut)
}

