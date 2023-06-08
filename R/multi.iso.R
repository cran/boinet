
#' Model averaging of multiple unimodal isotopic regression
#'
#' Given the location of the mode to be at each dose level, the unimodal
#' isotonically transformed values are calculated. A frequentist model
#' averaging approach is used to obtain the estimated efficacy probability.
#' @usage
#' multi.iso(obs, n)
#' @param obs Number of patients with events.
#' @param n Number of patients.
#' @return The \code{multi.iso} returns a vector of estimated probabilities for
#' each dose level.
#' @import Iso
#' @export

multi.iso <- function(obs, n)
{
  prob   <- obs/n
  ld     <- length(prob)
  unimod <- array(0,dim=c(ld,ld))
  AICk   <- numeric(ld)
  for(k in 1:ld){
    unimod[k,] <- (Iso::ufit(y=prob,x=(1:ld),lmod=k))$y
    Lk         <- prod(dbinom(obs,n,unimod[k,]))
    AICk[k]    <- (-2*log(Lk)+2*ld)
  }
  pik    <- exp(-AICk/2)/sum(exp(-AICk/2))
  pe.adj <- apply(as.matrix(1:ld),1,function(x){sum(pik*unimod[,x])})
  return(pe.adj)
}
