
#' Grid search to find optimal threshold values of toxicity and efficacy interval
#'
#' Given non-informative prior probabilities of the six hypotheses, a grid
#' search approach is used to find the optimal threshold values.
#' @usage
#' gridoptim(pi=rep(1/6,6), phi, phi1, phi2, delta, delta1, n=100)
#' @param pi Prior probability of 6 hypotheses. The default value is
#' \code{pi=rep(1/6,6)}.
#' @param phi Target toxicity probability.
#' @param phi1 Lower bound of toxicity probability.
#' @param phi2 Upper bound of toxicity probability.
#' @param delta Target efficacy probability.
#' @param delta1 Lower bound of efficacy probability.
#' @param n Number of patients. The default value is \code{n=100}.
#' @return The \code{gridoptim} returns optimal threshold values of upper and
#' lower toxicity/efficacy boundaries used in dose-escalation procedure.
#' @examples
#' gridoptim(phi=0.33,phi1=0.033,phi2=0.462,delta=0.70,delta1=0.42);
#' @export

gridoptim <- function(pi=rep(1/6,6), phi, phi1, phi2, delta, delta1, n=100)
{
  if(!((phi1<phi)&(phi<phi2))){
    stop("Design parameters must satisfy a condition of phi1 < phi < phi2.")
  }else if(!(delta1<delta)){
    stop("Design parameters must satisfy a condition of delta1 < delta.")
  }else{

  l1  <- round(seq(phi1,phi,by=0.01),digits=2)
  l1s <- length(l1)
  l2  <- round(seq(phi,phi2,by=0.01),digits=2)
  l2s <- length(l2)
  e1  <- round(seq(delta1,delta,by=0.01),digits=2)
  e1s <- length(e1)

  pincval <- array(0,dim=c(l1s,l2s,e1s))

  for(s1 in 1:l1s){
    for(s2 in 1:l2s){
      for(s3 in 1:e1s){

        l1p  <- pbinom(n*l1[s1],n,phi)
        l1p1 <- pbinom(n*l1[s1],n,phi1)
        l1p2 <- pbinom(n*l1[s1],n,phi2)

        l2p  <- pbinom(n*l2[s2]-1,n,phi)
        l2p1 <- pbinom(n*l2[s2]-1,n,phi1)
        l2p2 <- pbinom(n*l2[s2]-1,n,phi2)

        e1d  <- pbinom(n*e1[s3],n,delta)
        e1d1 <- pbinom(n*e1[s3],n,delta1)

        pincval[s1,s2,s3] <- (  pi[1]*(l1p1*(1-e1d1)             + 2/3*(l2p1-l1p1)*e1d1 + (l2p1-l1p1)*(1-e1d1)+(1-l2p1))
                              + pi[2]*(l1p1*e1d                  + 2/3*(l2p1-l1p1)*e1d  + (1-l2p1))
                              + pi[4]*(l1p*e1d                   + 2/3*(l2p-l1p1)*e1d   + (1-l2p))
                              + pi[5]*(l1p2*e1d1 + l1p2*(1-e1d1) + 2/3*(l2p2-l1p2)*e1d1 + (l2p2-l1p2)*(1-e1d1))
                              + pi[6]*(l1p2*e1d  + l1p2*(1-e1d)  + 2/3*(l2p2-l1p2)*e1d  + (l2p2-l1p2)*(1-e1d)))
  }}}

  pnum <- which(pincval==min(pincval),arr.ind=TRUE)
  ledf <- data.frame(lambda1=l1[pnum[1]],lambda2=l2[pnum[2]],eta1=e1[pnum[3]])

  return(ledf)

  }
}
