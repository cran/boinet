
#' TITE-gBOIN-ET: Time-to-Event Generalized BOIN Design for Ordinal Graded Outcomes
#'
#' @description
#' Conducts simulation studies of the TITE-gBOIN-ET (Time-to-Event generalized
#' Bayesian Optimal Interval design to accelerate dose-finding accounting for ordinal
#' graded Efficacy and Toxicity outcomes) design. This advanced extension incorporates
#' both time-to-event modeling and ordinal (graded) outcome assessment, making it
#' suitable for modern oncology trials where both the severity of toxicity and the
#' degree of efficacy response are clinically meaningful.
#'
#' The design addresses the reality that clinical outcomes are rarely binary. For
#' example, toxicity may range from mild (Grade 1) to life-threatening (Grade 4),
#' while efficacy can span from no response to complete response. By utilizing this
#' additional information, TITE-gBOIN-ET can make more informed dose selection
#' decisions while maintaining the advantages of time-to-event modeling for
#' delayed outcomes.
#'
#' @details
#' \strong{Key Advantages:}
#'
#' **1. Ordinal Outcome Modeling:**
#' Instead of binary toxicity/efficacy, the design uses:
#' \itemize{
#'   \item **Toxicity categories**: e.g., None, Mild, Moderate, Severe
#'   \item **Efficacy categories**: e.g., No Response, Partial Response, Complete Response
#'   \item **Weighted scoring**: Different severity levels receive different weights
#'   \item **Normalized equivalent scores**: nETS (toxicity) and nEES (efficacy)
#' }
#'
#' **2. Enhanced Information Utilization:**
#' The design captures more granular clinical information by considering:
#' \itemize{
#'   \item Grade 2 toxicity as different from Grade 4 toxicity
#'   \item Partial response as different from complete response
#'   \item Clinically meaningful gradations within traditional binary endpoints
#' }
#'
#' **3. Flexible Weighting Schemes:**
#' Users can specify custom weights reflecting clinical importance:
#' \itemize{
#'   \item **sev.weight**: Toxicity severity weights (e.g., 0, 0.5, 1.0, 1.5)
#'   \item **res.weight**: Efficacy response weights (e.g., 0, 0.25, 1.0, 3.0)
#' }
#'
#' \strong{Statistical Methodology:}
#'
#' **Equivalent Toxicity/Efficacy Scores:**
#'
#' The design converts ordinal outcomes to continuous scores:
#' \itemize{
#'   \item **ETS (Equivalent Toxicity Score)**: Weighted sum of toxicity categories
#'   \item **EES (Equivalent Efficacy Score)**: Weighted sum of efficacy categories
#'   \item **Normalization**: Scores divided by maximum possible weight (nETS, nEES)
#'   \item **Decision making**: Uses normalized scores with same boundaries as binary BOIN-ET
#' }
#'
#' **Time-to-Event Integration:**
#' Combines ordinal scoring with time-to-event methodology:
#' \itemize{
#'   \item Events can occur at different times within assessment windows
#'   \item Partial information from censored observations
#' }
#'
#' **Matrix Input Structure:**
#' Probability matrices define outcome distributions:
#' \itemize{
#'   \item **toxprob**: Matrix where rows = toxicity categories, columns = doses
#'   \item **effprob**: Matrix where rows = efficacy categories, columns = doses
#'   \item Row sums should equal 1 (probability distributions)
#'   \item Allows complex, realistic outcome scenarios
#' }
#'
#' @usage
#' tite.gboinet(
#'   n.dose, start.dose, size.cohort, n.cohort,
#'   toxprob, effprob, sev.weight, res.weight,
#'   phi, phi1 = phi*0.1, phi2 = phi*1.4,
#'   delta, delta1 = delta*0.6,
#'   alpha.T1 = 0.5, alpha.E1 = 0.5, tau.T, tau.E,
#'   te.corr = 0.2, gen.event.time = "weibull",
#'   accrual, gen.enroll.time = "uniform",
#'   stopping.npts = size.cohort*n.cohort,
#'   stopping.prob.T = 0.95, stopping.prob.E = 0.99,
#'   estpt.method = "obs.prob", obd.method = "max.effprob",
#'   w1 = 0.33, w2 = 1.09,
#'   plow.ast = phi1, pupp.ast = phi2,
#'   qlow.ast = delta1/2, qupp.ast = delta,
#'   psi00 = 40, psi11 = 60,
#'   n.sim = 1000, seed.sim = 100)
#'
#' @param n.dose Integer specifying the number of dose levels to investigate.
#' @param start.dose Integer specifying the starting dose level (1 = lowest dose).
#'   Generally recommended to start at the lowest dose for safety.
#' @param size.cohort Integer specifying the number of patients per cohort.
#'   Commonly 3 or 6 patients, with 3 being standard for early-phase trials.
#' @param n.cohort Integer specifying the maximum number of cohorts.
#'   Total sample size = size.cohort*n.cohort.
#' @param toxprob Matrix (nrow = toxicity categories, ncol = n.dose) specifying
#'   true toxicity probabilities. Each column must sum to 1.0. Rows represent
#'   ordered toxicity levels from none to most severe.
#' @param effprob Matrix (nrow = efficacy categories, ncol = n.dose) specifying
#'   true efficacy probabilities. Each column must sum to 1.0. Rows represent
#'   ordered response levels from none to best response.
#' @param sev.weight Numeric vector of toxicity severity weights. Length must
#'   equal nrow(toxprob). Should be non-decreasing and reflect clinical impact.
#'   First element typically 0 (no toxicity). Example: c(0, 0.5, 1.0, 1.5) for
#'   Grade 0 and 1, Grade 2, Grade 3, Grade 4.
#' @param res.weight Numeric vector of efficacy response weights. Length must
#'   equal nrow(effprob). Should be non-decreasing and reflect clinical benefit.
#'   First element typically 0 (no response). Example: c(0, 0.25, 1.0, 3.0) for
#'   PD, SD, PR, CR.
#' @param phi Numeric target for normalized equivalent toxicity score (nETS).
#'   Should be calibrated for weighted scores, not binary probabilities.
#' @param phi1 Numeric lower boundary for nETS. Doses with nETS <= phi1 considered
#'   under-dosed for toxicity. Default phi*0.1.
#' @param phi2 Numeric upper boundary for nETS. Doses with nETS >= phi2 trigger
#'   de-escalation. Default phi*1.4.
#' @param delta Numeric target for normalized equivalent efficacy score (nEES).
#'   Should reflect desired level of clinical benefit.
#' @param delta1 Numeric minimum threshold for nEES. Doses below this considered
#'   sub-therapeutic. Default delta*0.6.
#' @param alpha.T1 Numeric value specifying the probability that a toxicity outcome occurs
#'   in the late half of the toxicity assessment window. Used for event time generation.
#'   Default is 0.5.
#' @param alpha.E1 Numeric value specifying the probability that an efficacy outcome
#'   occurs in the late half of the efficacy assessment window. Used for event
#'   time generation. Default is 0.5.
#' @param tau.T Numeric value specifying the toxicity assessment window in days.
#' @param tau.E Numeric value specifying the efficacy assessment window in days.
#' @param te.corr Numeric value between -1 and 1 specifying the correlation between
#'   toxicity and efficacy, specified as Gaussian copula parameter. Default is 0.2
#'   (weak positive correlation).
#' @param gen.event.time Character string specifying the distribution for generating
#'   event times. Options are "weibull" (default) or "uniform". A bivariate
#'   Gaussian copula model is used to jointly generate the time to first ordinal toxicity
#'   and efficacy outcome, where the marginal distributions are set to Weibull
#'   distribution when \code{gen.event.time="weibull"}, and uniform distribution when
#'   \code{gen.event.time="uniform"}.
#' @param accrual Numeric value specifying the accrual rate (days), which is the
#'   average number of days between patient enrollments. Lower values indicate
#'   faster accrual.
#' @param gen.enroll.time Character string specifying the distribution for enrollment
#'   times. Options are "uniform" (default) or "exponential". Uniform distribution
#'   is used when \code{gen.enroll.time="uniform"}, and exponential distribution
#'   is used when \code{gen.enroll.time="exponential"}.
#' @param stopping.npts Integer specifying the maximum number of patients per dose
#'   for early study termination. If the number of patients at the current dose
#'   reaches this criteria, the study stops the enrollment and is terminated.
#'   Default is size.cohort*n.cohort.
#' @param stopping.prob.T Numeric value between 0 and 1 specifying the early study
#'   termination threshold for toxicity. If P(nETS > phi) > stopping.prob.T,
#'   the dose levels are eliminated from the investigation. Default is 0.95.
#' @param stopping.prob.E Numeric value between 0 and 1 specifying the early study
#'   termination threshold for efficacy. If P(nEES < delta1) > stopping.prob.E,
#'   the dose levels are eliminated from the investigation. Default is 0.99.
#' @param estpt.method Character string specifying the method for estimating efficacy
#'   probabilities. Options: "obs.prob" (observed efficacy probabilitiesrates),
#'   "fp.logistic" (fractional polynomial), or "multi.iso" (model averaging of
#'   multiple unimodal isotopic regression). Default is "obs.prob".
#' @param obd.method Character string specifying the method for OBD selection.
#'   Options: "utility.weighted", "utility.truncated.linear", "utility.scoring",
#'   or "max.effprob" (default).
#' @param w1 Numeric value specifying the weight for toxicity-efficacy trade-off
#'   in "utility.weighted" method. Default is 0.33.
#' @param w2 Numeric value specifying the penalty weight for toxic doses in
#'   "utility.weighted" method. Default is 1.09.
#' @param plow.ast Numeric value specifying the lower toxicity threshold for
#'   "utility.truncated.linear" method. Default is phi1.
#' @param pupp.ast Numeric value specifying the upper toxicity threshold for
#'   "utility.truncated.linear" method. Default is phi2.
#' @param qlow.ast Numeric value specifying the lower efficacy threshold for
#'   "utility.truncated.linear" method. Default is delta1/2.
#' @param qupp.ast Numeric value specifying the upper efficacy threshold for
#'   "utility.truncated.linear" method. Default is delta.
#' @param psi00 Numeric value specifying the utility score for (toxicity=no, efficacy=no)
#'   in "utility.scoring" method. Default is 40.
#' @param psi11 Numeric value specifying the utility score for (toxicity=yes, efficacy=yes)
#'   in "utility.scoring" method. Default is 60.
#' @param n.sim Integer specifying the number of simulated trials. Default is 1000.
#'   Higher values provide more stable operating characteristics.
#' @param seed.sim Integer specifying the random seed for reproducible results.
#'   Default is 100.
#'
#' @return
#' A list object of class "tite.gboinet" containing the following components:
#' \item{toxprob}{True toxicity probability matrix used in simulation.}
#' \item{effprob}{True efficacy probability matrix used in simulation.}
#' \item{nETS}{True normalized equivalent toxicity scores by dose level.}
#' \item{nEES}{True normalized equivalent efficacy scores by dose level.}
#' \item{phi}{Target normalized equivalent toxicity scores.}
#' \item{delta}{Target normalized equivalent efficacy scores.}
#' \item{lambda1}{Lower toxicity decision boundary.}
#' \item{lambda2}{Upper toxicity decision boundary.}
#' \item{eta1}{Lower efficacy decision boundary.}
#' \item{tau.T}{Toxicity assessment window (days).}
#' \item{tau.E}{Efficacy assessment window (days).}
#' \item{accrual}{Accrual rate (days).}
#' \item{ncat.T}{Number of ordinal toxicity outcome categories.}
#' \item{ncat.E}{Number of ordinal efficacy outcome categories.}
#' \item{estpt.method}{Method used for efficacy probability estimation.}
#' \item{obd.method}{Method used for optimal biological dose selection.}
#' \item{n.patient}{Average number of patients treated at each dose level across simulations.}
#' \item{prop.select}{Percentage of simulations selecting each dose level as OBD.}
#' \item{prop.stop}{Percentage of simulations terminating early without OBD selection.}
#' \item{duration}{Expected trial duration in days.}
#'
#' @examples
#' # Example: CAR-T therapy with graded CRS and response levels
#' # Scenario: 4 dose levels with detailed toxicity/efficacy grading
#'
#' n.dose      <- 4
#' start.dose  <- 1
#' size.cohort <- 6  # Larger cohorts for complex outcomes
#' n.cohort    <- 8
#'
#' # Toxicity categories: None, Mild CRS, Moderate CRS, Severe CRS
#' # Higher doses increase severe CRS probability
#' toxprob <- rbind(
#'   c(0.85, 0.70, 0.50, 0.30),  # No CRS
#'   c(0.10, 0.20, 0.25, 0.25),  # Mild CRS
#'   c(0.04, 0.08, 0.20, 0.30),  # Moderate CRS
#'   c(0.01, 0.02, 0.05, 0.15)   # Severe CRS
#' )
#'
#' # Efficacy categories: No response, Partial remission, Complete remission, MRD-negative
#' # Strong dose-response relationship
#' effprob <- rbind(
#'   c(0.70, 0.45, 0.25, 0.15),  # No response
#'   c(0.25, 0.35, 0.35, 0.25),  # Partial remission
#'   c(0.04, 0.15, 0.30, 0.40),  # Complete remission
#'   c(0.01, 0.05, 0.10, 0.20)   # MRD-negative CR
#' )
#'
#' # Clinical severity weights
#' sev.weight <- c(0.0, 0.3, 1.0, 2.5)    # Severe CRS heavily weighted
#' res.weight <- c(0.0, 0.5, 2.0, 4.0)    # Strong preference for deep responses
#'
#' # CAR-T appropriate parameters
#' phi   <- 0.40  # Accept moderate weighted toxicity
#' delta <- 0.80  # Target substantial weighted efficacy
#'
#' # Extended assessment for immune effects
#' tau.T   <- 84   # 12 weeks for CRS resolution
#' tau.E   <- 168  # 24 weeks for response assessment
#' accrual <- 14   # Bi-weekly enrollment
#'
#' # Delayed and correlated outcomes
#' alpha.T1 <- 0.4  # Earlier CRS onset
#' alpha.E1 <- 0.8  # Much delayed responses
#' te.corr  <- 0.4  # Moderate positive correlation
#'
#' results_cart <- tite.gboinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   sev.weight = sev.weight, res.weight = res.weight,
#'   phi = phi, delta = delta,
#'   alpha.T1 = alpha.T1, alpha.E1 = alpha.E1,
#'   tau.T = tau.T, tau.E = tau.E,
#'   te.corr = te.corr, accrual = accrual,
#'   estpt.method = "obs.prob",
#'   obd.method = "utility.weighted",
#'   w1 = 0.5, w2 = 1.5,  # Balance with strong toxicity penalty
#'   n.sim = 40
#' )
#'
#' # Display normalized equivalent scores
#' cat("Normalized Equivalent Toxicity Scores (nETS):\\n")
#' print(results_cart$nETS)
#' cat("Normalized Equivalent Efficacy Scores (nEES):\\n")
#' print(results_cart$nEES)
#'
#' cat("OBD Selection Probabilities:\\n")
#' print(results_cart$prop.select)
#'
#' @note
#' \itemize{
#'   \item Probability matrices must have rows summing to 1.0 for each dose
#'   \item Weight vectors must have same length as corresponding outcome categories
#'   \item Normalized scores may require different target values than binary probabilities
#' }
#'
#' @references
#' \itemize{
#'   \item Takeda, K., Yamaguchi, Y., Taguri, M., & Morita, S. (2023). TITE-gBOIN-ET:
#'         Time-to-event generalized Bayesian optimal interval design to accelerate
#'         dose-finding accounting for ordinal graded efficacy and toxicity outcomes.
#'         \emph{Biometrical Journal}, 65(7), e2200265.
#'   \item Yamaguchi, Y., Takeda, K., Yoshida, S., & Maruo, K. (2024). Optimal
#'         biological dose selection in dose-finding trials with model-assisted designs
#'         based on efficacy and toxicity: a simulation study. \emph{Journal of
#'         Biopharmaceutical Statistics}, 34(3), 379-393.
#' }
#'
#' @seealso
#' \code{\link{tite.boinet}} for binary outcome version,
#' \code{\link{gboinet}} for non-time-to-event ordinal version,
#' \code{\link{obd.select}} for dose selection methods,
#' \code{\link{utility.weighted}}, \code{\link{utility.truncated.linear}},
#' \code{\link{utility.scoring}} for utility functions.
#'
#' @keywords clinical-trials ordinal-outcomes time-to-event TITE-gBOIN-ET graded-outcomes
#' @import Iso copula
#' @importFrom stats binomial dbinom pbeta pbinom rmultinom runif rexp
#' @export


tite.gboinet <- function(
                  n.dose, start.dose, size.cohort, n.cohort,
                  toxprob, effprob, sev.weight, res.weight,
                  phi, phi1=phi*0.1, phi2=phi*1.4, delta, delta1=delta*0.6,
                  alpha.T1=0.5, alpha.E1=0.5, tau.T, tau.E,
                  te.corr=0.2, gen.event.time="weibull",
                  accrual, gen.enroll.time="uniform",
                  stopping.npts=size.cohort*n.cohort,
                  stopping.prob.T=0.95, stopping.prob.E=0.99,
                  estpt.method = "obs.prob", obd.method = "max.effprob",
                  w1=0.33, w2=1.09,
                  plow.ast=phi1, pupp.ast=phi2, qlow.ast=delta1/2, qupp.ast=delta,
                  psi00=40, psi11=60,
                  n.sim=1000, seed.sim=100)
{
  if(ncol(toxprob)!=n.dose){
    stop("Number of dose must be the same as the length of true toxicity probability.")

  }else if(ncol(effprob)!=n.dose){
    stop("Number of dose must be the same as the length of true efficacy probability.")

  }else if(nrow(toxprob)!=length(sev.weight)){
    stop("Number of toxicity category must be the same as the length of weight.")

  }else if(nrow(effprob)!=length(res.weight)){
    stop("Number of effcacy category must be the same as the length of weight.")

  }else if(!((phi1<phi)&(phi<phi2))){
    stop("Design parameters must satisfy a condition of phi1 < phi < phi2.")

  }else if(!(delta1<delta)){
    stop("Design parameters must satisfy a condition of delta1 < delta.")

  }else if((!is.matrix(toxprob))|(!is.matrix(effprob))){
    stop("True toxicity and efficacy probability must be specified as matrix.")

  }else{

  dosen <- 1:n.dose
  dose  <- paste("Dose",dosen,sep="")

  toxp <- data.frame(toxprob)
  colnames(toxp) <- dose

  effp <- data.frame(effprob)
  colnames(effp) <- dose

  ncat.T <- nrow(toxp)-1
  ncat.E <- nrow(effp)-1

  ncoh <- size.cohort
  nesc <- n.cohort
  nmax <- ncoh*nesc

  design.par <- gridoptim(phi=phi,phi1=phi1,phi2=phi2,delta=delta,delta1=delta1)

  lambda1 <- design.par$lambda1
  lambda2 <- design.par$lambda2
  eta1    <- design.par$eta1

  pr.alpha <- 1
  pr.beta  <- 1

  alpha.T1 <- alpha.T1
  alpha.T2 <- 0.5
  alpha.E1 <- alpha.E1
  alpha.E2 <- 0.5

  efftoxp <- list(toxp=toxp,effp=effp)

  ncop    <- copula::normalCopula(te.corr,dim=2,dispstr="ex")
  mv.ncop <- NULL

  if(gen.event.time=="weibull"){

    for(i in 1:n.dose){
      psi.T    <- sum(efftoxp$toxp[-1,i])
      zetta.T1 <- log(log(1-psi.T)/log(1-psi.T+alpha.T1*psi.T))/log(1/(1-alpha.T2))
      zetta.T2 <- tau.T/(-log(1-psi.T))^(1/zetta.T1)

      psi.E    <- sum(efftoxp$effp[-1,i])
      zetta.E1 <- log(log(1-psi.E)/log(1-psi.E+alpha.E1*psi.E))/log(1/(1-alpha.E2))
      zetta.E2 <- tau.E/(-log(1-psi.E))^(1/zetta.E1)

      mv.ncop <- append(mv.ncop,copula::mvdc(copula       = ncop,
                                             margins      = c("weibull","weibull"),
                                             paramMargins = list(list(shape=zetta.T1,scale=zetta.T2),
                                                                 list(shape=zetta.E1,scale=zetta.E2))))
    }

  }else if(gen.event.time=="uniform"){

    for(i in 1:n.dose){
      psi.T <- sum(efftoxp$toxp[-1,i])
      psi.E <- sum(efftoxp$effp[-1,i])

      mv.ncop <- append(mv.ncop,copula::mvdc(copula       = ncop,
                                             margins      = c("unif","unif"),
                                             paramMargins = list(list(min=0,max=tau.T*(1/psi.T)),
                                                                 list(min=0,max=tau.E*(1/psi.E)))))
    }

  }

  data.obs.n <- array(0,dim=c(n.sim,n.dose))
  data.dur   <- array(0,dim=c(n.sim))

  obd <- array(0,dim=c(n.sim))

  set.seed(seed.sim)

  for(ss in 1:n.sim){

    obs.n     <- numeric(n.dose)
    obs.tox   <- numeric(n.dose)
    obs.tox.n <- numeric(n.dose)
    obs.eff   <- numeric(n.dose)
    obs.eff.n <- numeric(n.dose)
    pe        <- numeric(n.dose)
    pt        <- numeric(n.dose)

    t.enter    <- NULL
    t.decision <- 0
    tite.df    <- NULL

    curdose <- start.dose

    early.stop <- 0

    for(i in 1:nesc){
      dlab <- paste("Dose",curdose,sep="")
      obs.n[curdose] <- obs.n[curdose] + ncoh

      for(j in 1:ncoh){
        if(j==1){
          t.enter[j] <- t.decision
        }else{
          if(gen.enroll.time=="uniform"){
            t.enter[j] <- t.enter[j-1]+runif(1,0,2*accrual)
          }else if(gen.enroll.time=="exponential"){
            t.enter[j] <- t.enter[j-1]+rexp(1,1/accrual)
          }
      }}

      if(i==nesc){
        t.decision <- t.enter[length(t.enter)]+max(tau.T,tau.E)
      }else{
        if(gen.enroll.time=="uniform"){
          t.decision <- t.enter[length(t.enter)]+runif(1,0,2*accrual)
        }else if(gen.enroll.time=="exponential"){
          t.decision <- t.enter[length(t.enter)]+rexp(1,1/accrual)
        }
      }

      time.te <- copula::rMvdc(ncoh,mv.ncop[[curdose]])

      event.T  <- as.numeric(time.te[,1]<=tau.T)
      grade    <- event.T*((1:ncat.T)%*%rmultinom(ncoh,1,efftoxp$toxp[-1,dlab]))+1
      ETS      <- apply(grade,2,function(x){return(sev.weight[x])})
      nETS     <- ETS/max(sev.weight)

      event.E  <- as.numeric(time.te[,2]<=tau.E)
      response <- event.E*((1:ncat.E)%*%rmultinom(ncoh,1,efftoxp$effp[-1,dlab]))+1
      EES      <- apply(response,2,function(x){return(res.weight[x])})
      nEES     <- EES/max(res.weight)

      tite.df <- rbind(tite.df,
                       data.frame(dose   = curdose,
                                  enter  = t.enter,
                                  endtox = t.enter+apply(as.matrix(1:ncoh),1,function(x){min(time.te[x,1],tau.T)}),
                                  nets   = nETS,
                                  endeff = t.enter+apply(as.matrix(1:ncoh),1,function(x){min(time.te[x,2],tau.E)}),
                                  nees   = nEES))

      tite.curdose <- tite.df[tite.df$dose==curdose,]
      gamma.T <- as.numeric(tite.curdose$endtox<=t.decision)
      gamma.E <- as.numeric(tite.curdose$endeff<=t.decision)

      while(mean(gamma.T*gamma.E)<0.5){
        nextdec.T  <- tite.curdose[tite.curdose$endtox>t.decision,"endtox"]
        nextdec.E  <- tite.curdose[tite.curdose$endeff>t.decision,"endeff"]
        t.decision <- min(nextdec.T,nextdec.E)
        gamma.T    <- as.numeric(tite.curdose$endtox<=t.decision)
        gamma.E    <- as.numeric(tite.curdose$endeff<=t.decision)
      }

      gamma.all.T <- as.numeric(tite.df$endtox<=t.decision)
      gamma.all.E <- as.numeric(tite.df$endeff<=t.decision)

      for(ds in 1:n.dose){
        if(sum(tite.df$dose==ds)>0){

          compsub.T <- tite.df[(tite.df$endtox<=t.decision)&(tite.df$dose==ds),]
          pendsub.T <- tite.df[(tite.df$endtox >t.decision)&(tite.df$dose==ds),]
          compsub.E <- tite.df[(tite.df$endeff<=t.decision)&(tite.df$dose==ds),]
          pendsub.E <- tite.df[(tite.df$endeff >t.decision)&(tite.df$dose==ds),]

          x.nETS <- sum(compsub.T$nets)
          n.nETS <- x.nETS+sum(1-compsub.T$nets)+sum(t.decision-pendsub.T$enter)/tau.T

          x.nEES <- sum(compsub.E$nees)
          n.nEES <- x.nEES+sum(1-compsub.E$nees)+sum(t.decision-pendsub.E$enter)/tau.E

          obs.tox[ds]   <- x.nETS
          obs.tox.n[ds] <- n.nETS
          pt[ds]        <- x.nETS/n.nETS

          obs.eff[ds]   <- x.nEES
          obs.eff.n[ds] <- n.nEES
          pe[ds]        <- x.nEES/n.nEES

      }}

      if((pt[curdose]<=lambda1)&(pe[curdose]<=eta1)){
        nxtdose <- curdose+1
      }else if((pt[curdose]<lambda2)&(pe[curdose]>eta1)){
        nxtdose <- curdose
      }else if(pt[curdose]>=lambda2){
        nxtdose <- curdose-1

      }else if((pt[curdose]>lambda1)&(pt[curdose]<lambda2)&(pe[curdose]<=eta1)){

        if(curdose==n.dose){
          three    <- c(curdose-1,curdose)
          maxpe    <- max(pe[three])
          maxpe.ds <- dosen[which((pe==maxpe)&(is.element(dosen,three)))]
          if(length(maxpe.ds)==1){
            nxtdose <- maxpe.ds
          }else{
            nxtdose <- sample(maxpe.ds,1)
          }

        }else if(obs.n[curdose+1]==0){
          nxtdose <- curdose+1

        }else if(curdose==1){
          three    <- c(curdose,curdose+1)
          maxpe    <- max(pe[three])
          maxpe.ds <- dosen[which((pe==maxpe)&(is.element(dosen,three)))]
          if(length(maxpe.ds)==1){
            nxtdose <- maxpe.ds
          }else{
            nxtdose <- sample(maxpe.ds,1)
          }

        }else{
          three    <- c(curdose-1,curdose,curdose+1)
          maxpe    <- max(pe[three])
          maxpe.ds <- dosen[which((pe==maxpe)&(is.element(dosen,three)))]
          if(length(maxpe.ds)==1){
            nxtdose <- maxpe.ds
          }else{
            nxtdose <- sample(maxpe.ds,1)
          }
        }
      }

      po.shape1 <- pr.alpha + obs.tox
      po.shape2 <- pr.beta  + (obs.n-obs.tox)
      tterm     <- pbeta(phi,po.shape1,po.shape2)

      po.shape1 <- pr.alpha + obs.eff
      po.shape2 <- pr.beta  + (obs.n-obs.eff)
      eterm     <- 1-pbeta(delta1,po.shape1,po.shape2)

      admflg  <- !((eterm<(1-stopping.prob.E))|(tterm<(1-stopping.prob.T)))
      admdose <- dosen[admflg]

      if(sum(admflg)==0){
        early.stop <- 1
        break

      }else if(sum(obs.n>=stopping.npts)>0){
        break

      }else{

        if(nxtdose==0){
          if(admflg[1]){
            curdose <- 1
          }else{
            early.stop <- 1
            break
          }

        }else if(nxtdose==(n.dose+1)){
          curdose <- n.dose

        }else if(is.element(nxtdose,admdose)){
          curdose <- nxtdose

        }else if(curdose<nxtdose){
          if(sum(admdose>=nxtdose)!=0){
            curdose <- min(admdose[admdose>=nxtdose])
          }

        }else if(curdose>=nxtdose){
          if(sum(admdose<=nxtdose)!=0){
            curdose <- max(admdose[admdose<=nxtdose])
          }else{
            early.stop <- 1
            break
          }
      }}
    }

    data.obs.n[ss,] <- obs.n
    data.dur[ss]    <- t.decision

    evadose <- dosen[obs.n!=0]
    obspt <- obs.tox[evadose]/obs.n[evadose]
    obspe <- obs.eff[evadose]/obs.n[evadose]

    tterm.obd <- numeric(n.dose)
    eterm.obd <- numeric(n.dose)

    for(i in evadose){
      po.shape1    <- pr.alpha + obs.tox[i]
      po.shape2    <- pr.beta  + (obs.n[i]-obs.tox[i])
      tterm.obd[i] <- pbeta(phi,po.shape1,po.shape2)

      po.shape1    <- pr.alpha + obs.eff[i]
      po.shape2    <- pr.beta  + (obs.n[i]-obs.eff[i])
      eterm.obd[i] <- 1-pbeta(delta1,po.shape1,po.shape2)
    }

    if(early.stop==1){

      obd[ss] <- 0

    }else if(length(evadose)==1){

      if((tterm.obd[evadose]>=(1-stopping.prob.T))&(eterm.obd[evadose]>=(1-stopping.prob.E))){
        obd[ss] <- evadose
      }

    }else if(sum((tterm.obd[evadose]>=(1-stopping.prob.T))&(eterm.obd[evadose]>=(1-stopping.prob.E)))>=1){

      estpt <- Iso::pava(obspt)

      if(estpt.method=="multi.iso"){
        estpe <- multi.iso(obs=obs.eff[evadose],n=obs.n[evadose])

      }else if(estpt.method=="fp.logistic"){
        estpe <- fp.logit(obs=obs.eff[evadose],n=obs.n[evadose],dose=evadose)

      }else if(estpt.method=="obs.prob"){
        estpe <- obspe
      }

      obd[ss] <- obd.select(
                   probt=estpt, probe=estpe, method=obd.method,
                   phi=phi, phi1=phi1, phi2=phi2, delta=delta, delta1=delta1,
                   tterm=tterm.obd[evadose], eterm=eterm.obd[evadose],
                   stopT=stopping.prob.T, stopE=stopping.prob.E,
                   w1=w1, w2=w2,
                   plow.ast=plow.ast, pupp.ast=pupp.ast, qlow.ast=qlow.ast, qupp.ast=qupp.ast,
                   psi00=psi00, psi11=psi11)
    }
  }

  prop.select <- array(0,dim=c(n.dose))
  for(i in 1:n.dose){
    prop.select[i] <- round(mean(obd==i)*100,digits=1)
  }
  names(prop.select) <- dose

  prop.stop <- round(mean(obd==0)*100,digits=1)
  names(prop.stop) <- "No OBD %"

  n.patient <- round(apply(data.obs.n,2,mean),digits=1)
  names(n.patient) <- dose

  duration  <- round(mean(data.dur),digits=1)
  names(duration) <- "Trial duration (days)"

  t.nets <- round(apply(apply(toxprob,2,function(x)x*sev.weight/max(sev.weight)),2,sum),digits=2)
  t.nees <- round(apply(apply(effprob,2,function(x)x*res.weight/max(res.weight)),2,sum),digits=2)

  dimnames(toxprob)   <- list(paste("Tox.cat",1:(ncat.T+1),sep=""),dose)
  dimnames(effprob)   <- list(paste("Eff.cat",1:(ncat.E+1),sep=""),dose)
  names(phi)          <- "Target toxicity prob."
  names(delta)        <- "Target efficacy prob."
  names(lambda1)      <- "Lower toxicity boundary"
  names(lambda2)      <- "Upper toxicity boundary"
  names(eta1)         <- "Lower efficacy boundary"
  names(tau.T)        <- "Tox. assessment window (days)"
  names(tau.E)        <- "Eff. assessment window (days)"
  names(accrual)      <- "Accrual rate (days)"
  names(ncat.T)       <- "Number of toxicity category"
  names(ncat.E)       <- "Number of efficacy category"
  names(estpt.method) <- "Efficacy prob. estimation"
  names(obd.method)   <- "OBD selection"

  result <- list(toxprob      = toxprob,
                 effprob      = effprob,
                 nETS         = t.nets,
                 nEES         = t.nees,
                 phi          = phi,
                 delta        = delta,
                 lambda1      = lambda1,
                 lambda2      = lambda2,
                 eta1         = eta1,
                 tau.T        = tau.T,
                 tau.E        = tau.E,
                 accrual      = accrual,
                 ncat.T       = ncat.T+1,
                 ncat.E       = ncat.E+1,
                 estpt.method = estpt.method,
                 obd.method   = obd.method,
                 n.patient    = n.patient,
                 prop.select  = prop.select,
                 prop.stop    = prop.stop,
                 duration     = duration)

  class(result) <- "tite.gboinet"
  result

}}






