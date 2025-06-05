
#' Grid Search Optimization for BOIN-ET Design Boundaries
#'
#' @description
#' Performs grid search optimization to determine optimal threshold values for
#' toxicity and efficacy boundaries used in BOIN-ET dose-escalation and de-escalation
#' decisions. This function implements the foundational calibration step for
#' Bayesian Optimal Interval designs, ensuring that the decision boundaries
#' (lambda1, lambda2, eta1) are optimally chosen to minimize incorrect dose
#' selection decisions across various clinical scenarios.
#'
#' The optimization process balances the competing objectives of avoiding under-dosing
#' (missing therapeutic opportunities), over-dosing (exposing patients to excessive
#' toxicity), and selecting ineffective doses (futility), making it critical for
#' the overall performance of BOIN-ET designs.
#'
#' @details
#' The grid search optimization addresses the fundamental problem in dose-finding:
#' determining decision boundaries that minimize the probability of incorrect dosing
#' decisions. The method considers six possible true dose-response scenarios:
#'
#' \strong{Grid Search Methodology:}
#'
#' **Search Space Construction:**
#' \itemize{
#'   \item **lambda1 range**: (phi1,phi) in 0.01 increments
#'   \item **lambda2 range**: (phi,phi2) in 0.01 increments
#'   \item **eta1 range**: (delta1,delta) in 0.01 increments
#'   \item **Total combinations**: Typically 50-200 combinations depending on ranges
#' }
#'
#' **Evaluation Criteria:**
#' For each boundary combination, the function calculates the probability of
#' incorrect selection by:
#' \enumerate{
#'   \item Computing decision probabilities under each hypothesis
#'   \item Weighting by prior hypothesis probabilities
#'   \item Summing across all incorrect decision scenarios
#'   \item Selecting boundaries that minimize total probability of incorrect decision
#' }
#'
#' @usage
#' gridoptim(pi = rep(1/6, 6), phi, phi1, phi2, delta, delta1, n = 100)
#'
#' @param pi Numeric vector of length 6 specifying prior probabilities for the
#'   six dose-response hypotheses. Must sum to 1. Default is uniform priors
#'   (rep(1/6, 6)). Order corresponds to: (1) under-dosed both, (2) under-dosed
#'   toxicity only, (3) adequate both, (4) adequate toxicity only, (5) over-dosed
#'   toxicity/adequate efficacy, (6) over-dosed toxicity/under-dosed efficacy.
#' @param phi Numeric value specifying the target toxicity probability.
#'   Must satisfy phi1 < phi < phi2.
#' @param phi1 Numeric value specifying the lower bound of acceptable toxicity
#'   probability range. Doses with toxicity <= phi1 are considered under-dosed
#'   for toxicity. Must be less than phi.
#' @param phi2 Numeric value specifying the upper bound of acceptable toxicity
#'   probability range. Doses with toxicity >= phi2 are considered over-dosed.
#'   Must be greater than phi.
#' @param delta Numeric value specifying the target efficacy probability. This
#'   represents the desired minimum efficacy rate. Must be greater than delta1.
#' @param delta1 Numeric value specifying the lower bound of efficacy probability
#'   range. Doses with efficacy < delta1 are considered sub-therapeutic.
#'   Must be less than delta.
#' @param n Numeric value specifying the reference sample size for boundary
#'   optimization. Default is 100. This affects the granularity of decision
#'   probabilities but optimal boundaries are relatively robust to this choice
#'   within typical phase I sample size ranges.
#'
#' @return
#' A data frame containing the optimal boundary values:
#' \item{lambda1}{Optimal lower toxicity boundary for dose escalation decisions.}
#' \item{lambda2}{Optimal upper toxicity boundary for dose de-escalation decisions.}
#' \item{eta1}{Optimal lower efficacy boundary for dose selection decisions.}
#'
#' These boundaries should satisfy: phi1 <= lambda1 <= phi <= lambda2 <= phi2 and
#' delta1 <= eta1 <= delta.
#'
#' @examples
#' phi <- 0.30      # 30% target toxicity
#' phi1 <- 0.05     # 5% lower toxicity bound
#' phi2 <- 0.45     # 45% upper toxicity bound
#' delta <- 0.60    # 60% target efficacy
#' delta1 <- 0.35   # 35% minimum efficacy threshold
#'
#' optimal_boundaries <- gridoptim(
#'   phi = phi, phi1 = phi1, phi2 = phi2,
#'   delta = delta, delta1 = delta1
#' )
#'
#' print(optimal_boundaries)
#'
#' # Verify boundary relationships
#' cat("\\nBoundary Verification:\\n")
#' cat("phi1 <= lambda1 <= phi:", phi1, "<=", optimal_boundaries$lambda1, "<=", phi,
#'     "->", phi1 <= optimal_boundaries$lambda1 && optimal_boundaries$lambda1 <= phi, "\\n")
#' cat("phi <= lambda2 <= phi2:", phi, "<=", optimal_boundaries$lambda2, "<=", phi2,
#'     "->", phi <= optimal_boundaries$lambda2 && optimal_boundaries$lambda2 <= phi2, "\\n")
#' cat("delta1 <= eta1 <= delta:", delta1, "<=", optimal_boundaries$eta1, "<=", delta,
#'     "->", delta1 <= optimal_boundaries$eta1 && optimal_boundaries$eta1 <= delta, "\\n")
#'
#' @note
#' \itemize{
#'   \item Parameter constraints must be satisfied: phi1 < phi < phi2 and delta1 < delta
#'   \item Prior probabilities in pi must sum to 1.0
#'   \item Grid search resolution is 0.01, providing good balance of precision and speed
#'   \item Results are relatively robust to moderate changes in reference sample size (n)
#' }
#'
#' @references
#' \itemize{
#'   \item Takeda, K., Taguri, M., & Morita, S. (2018). BOIN-ET: Bayesian optimal
#'         interval design for dose finding based on both efficacy and toxicity outcomes.
#'         \emph{Pharmaceutical Statistics}, 17(4), 383-395.
#' }
#'
#' @seealso
#' \code{\link{boinet}} and \code{\link{tite.boinet}} which use optimized boundaries,
#' \code{\link{obd.select}} for dose selection using the optimized boundaries.
#'
#' @export

gridoptim <- function(pi=rep(1/6,6), phi, phi1, phi2, delta, delta1, n=100)
{
  if(!((phi1<phi)&(phi<phi2))){
    stop("Design parameters must satisfy a condition of phi1 < phi < phi2.")
  }else if(!(delta1<delta)){
    stop("Design parameters must satisfy a condition of delta1 < delta.")
  }else{

  l1  <- seq(phi1,phi,by=0.01)
  l1s <- length(l1)
  l2  <- seq(phi,phi2,by=0.01)
  l2s <- length(l2)
  e1  <- seq(delta1,delta,by=0.01)
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
  ledf <- data.frame(lambda1=l1[pnum[1,1]],lambda2=l2[pnum[1,2]],eta1=e1[pnum[1,3]])

  return(ledf)

  }
}
