
#' Optimal biological dose selection
#'
#' Optimal biological dose (OBD) is selected based on a method specified.
#' @param probt Estimated toxicity probability.
#' @param probe Estimated efficacy probability.
#' @param method Method used for OBD selection.
#' @param phi Target toxicity probability.
#' @param phi1 Lower bound of toxicity probability.
#' @param phi2 Upper bound of toxicity probability.
#' @param delta Target efficacy probability.
#' @param delta1 Lower bound of efficacy probability.
#' @param tterm Probability of meeting toxicity stopping criteria.
#' @param eterm Probability of meeting efficacy stopping criteria.
#' @param stopT Toxicity stopping criteria.
#' @param stopE Efficacy stopping criteria.
#' @param w1 Weight for toxicity-efficacy trade-off.
#' @param w2 Weight for penalty imposed on toxic doses.
#' @param plow.ast Lower threshold of toxicity linear truncated function.
#' @param pupp.ast Upper threshold of toxicity linear truncated function.
#' @param qlow.ast Lower threshold of efficacy linear truncated function.
#' @param qupp.ast Upper threshold of efficacy linear truncated function.
#' @param psi00 Score for toxicity=no and efficacy=no.
#' @param psi11 Score for toxicity=yes and efficacy=yes.
#' @return Optimal biological dose
#' @export

obd.select <- function(
                probt, probe, method,
                phi, phi1, phi2, delta, delta1,
                tterm, eterm, stopT, stopE,
                w1, w2,
                plow.ast, pupp.ast, qlow.ast, qupp.ast,
                psi00, psi11)
{
  candose <- which((tterm>=(1-stopT))&(eterm>=(1-stopE)))

  if(method=="utility.weighted"){
    fu <- utility.weighted(probt=probt,probe=probe,
                           w1=w1,w2=w2,tox.upper=phi2)
    fu.max <- which(fu==max(fu[candose]))
    re     <- min(intersect(fu.max,candose))

  }else if(method=="utility.truncated.linear"){
    fu <- utility.truncated.linear(probt=probt,probe=probe,
                                   tlow=plow.ast,tupp=pupp.ast,
                                   elow=qlow.ast,eupp=qupp.ast)
    fu.max <- which(fu==max(fu[candose]))
    re     <- min(intersect(fu.max,candose))

  }else if(method=="utility.scoring"){
    fu <- utility.scoring(probt=probt,probe=probe,
                          psi00=psi00,psi11=psi11)
    fu.max <- which(fu==max(fu[candose]))
    re     <- min(intersect(fu.max,candose))

  }else if(method=="max.effprob"){
    mdif <- min(abs(probt[candose]-phi))
    mtd  <- max(which(abs(probt-phi)==mdif))
    meff <- max(probe[intersect(candose,1:mtd)])
    deff <- which(probe==meff)
    re   <- min(intersect(candose,deff))
  }

  return(re)
}
