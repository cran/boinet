
#' gBOIN-ET: Generalized Bayesian Optimal Interval Design for Ordinal Graded Outcomes
#'
#' @description
#' Conducts simulation studies of the gBOIN-ET (generalized Bayesian Optimal Interval
#' design for optimal dose-finding accounting for ordinal graded Efficacy and Toxicity)
#' design. This extension of BOIN-ET utilizes ordinal (graded) outcome information
#' rather than binary endpoints, providing more nuanced dose-finding decisions by
#' incorporating the full spectrum of toxicity severity and efficacy response levels.
#'
#' Unlike traditional binary approaches that classify outcomes as simply "toxic/non-toxic"
#' or "effective/ineffective," gBOIN-ET recognizes that clinical outcomes exist on a
#' continuum. This design is particularly valuable when the degree of toxicity or
#' efficacy response significantly impacts clinical decision-making and patient outcomes.
#'
#' @details
#' \strong{Conceptual Foundation:}
#'
#' **Binary vs Ordinal Paradigm:**
#' Traditional designs lose valuable information by dichotomizing outcomes:
#' \itemize{
#'   \item **Binary approach**: Grade 3 or Grade 4 toxicity treated identically as "toxic"
#'   \item **Ordinal approach**: Preserves clinically meaningful distinctions between severity levels
#'   \item **Information gain**: More efficient use of patient data for dose-finding decisions
#' }
#'
#' **Equivalent Toxicity/Efficacy Score Framework:**
#' The design converts ordinal categories into continuous scores:
#' \itemize{
#'   \item **ETS (Equivalent Toxicity Score)**: Relative severity of different toxicity grades
#'   \item **EES (Equivalent Efficacy Score)**: Relative effectiveness of different efficacy outcomes
#'   \item **Normalized scores (nETS, nEES)**: Standardized to a scale ranging from 0 to 1 (quasi-Bernoulli probability)
#' }
#'
#' **Decision Algorithm:**
#' Uses the same boundary-based logic as BOIN-ET but applied to normalized scores:
#' \itemize{
#'   \item **Escalate**: When nETS <= lambda1 AND nEES <= eta1
#'   \item **Stay**: When lambda1 < nETS < lambda2 AND nEES > eta1
#'   \item **De-escalate**: When nETS >= lambda2
#'   \item **Efficacy-guided**: When lambda1 < nETS < lambda2 AND nEES <= eta1
#' }
#'
#' \strong{Key Advantages:}
#'
#' **1. Enhanced Discrimination:**
#' \itemize{
#'   \item Better differentiation between dose levels with similar binary rates
#'   \item Captures clinically meaningful severity gradations
#' }
#'
#' **2. Clinical Relevance:**
#' \itemize{
#'   \item Aligns with clinical practice where severity matters
#'   \item Better reflection of risk-benefit trade-offs
#' }
#'
#' **3. Regulatory Appeal:**
#' \itemize{
#'   \item Utilizes standard grading systems (CTCAE, RECIST)
#'   \item Transparent scoring methodology
#'   \item Maintains model-assisted design simplicity
#' }
#'
#' \strong{Weight Selection:}
#'
#' **Example of Toxicity Weights (sev.weight):**
#' Should reflect clinical impact and patient burden:
#' \itemize{
#'   \item **Grade 0 and 1**: 0.0
#'   \item **Grade 2**: 0.5
#'   \item **Grade 3**: 1.0
#'   \item **Grade 4**: 1.5
#' }
#'
#' **Example of Efficacy Weights (res.weight):**
#' Should reflect clinical benefit and durability:
#' \itemize{
#'   \item **PD**: 0.0
#'   \item **SD**: 0.25
#'   \item **PR**: 1.0
#'   \item **CR**: 3.0
#' }
#'
#' \strong{When to Use gBOIN-ET vs TITE-gBOIN-ET:}
#'
#' **Choose gBOIN-ET when:**
#' \itemize{
#'   \item Outcomes occur within reasonable assessment windows
#'   \item Patient accrual allows waiting for complete outcome assessment
#'   \item Preference for simpler, well-established approaches
#' }
#'
#' **Choose TITE-gBOIN-ET when:**
#' \itemize{
#'   \item Late-onset outcomes are expected
#'   \item Rapid accrual necessitates continuous enrollment
#'   \item Trial duration constraints are critical
#' }
#'
#' @usage
#' gboinet(
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
#'   First element typically 0 (no toxicity).
#' @param res.weight Numeric vector of efficacy response weights. Length must
#'   equal nrow(effprob). Should be non-decreasing and reflect clinical benefit.
#'   First element typically 0 (no response).
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
#'   All toxicity evaluations must be completed within this period.
#' @param tau.E Numeric value specifying the efficacy assessment window in days.
#'   All efficacy evaluations must be completed within this period.
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
#' A list object of class "gboinet" containing the following components:
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
#' # Example 1: Targeted therapy with hepatotoxicity grading
#' # Scenario: Kinase inhibitor with dose-dependent liver toxicity
#'
#' n.dose      <- 5
#' start.dose  <- 1
#' size.cohort <- 4  # Slightly larger for ordinal information
#' n.cohort    <- 12
#'
#' # Hepatotoxicity categories: Normal, Grade 1, Grade 2, Grade 3+
#' # Progressive increase in severe hepatotoxicity with dose
#' toxprob <- rbind(
#'   c(0.85, 0.70, 0.50, 0.35, 0.20),  # Normal LFTs
#'   c(0.12, 0.20, 0.25, 0.25, 0.20),  # Grade 1 elevation
#'   c(0.02, 0.08, 0.20, 0.30, 0.40),  # Grade 2 elevation
#'   c(0.01, 0.02, 0.05, 0.10, 0.20)   # Grade 3+ hepatotoxicity
#' )
#'
#' # Response categories: PD, SD, PR, CR
#' # Plateau in efficacy at higher doses
#' effprob <- rbind(
#'   c(0.70, 0.50, 0.30, 0.25, 0.30),  # Progressive disease
#'   c(0.25, 0.35, 0.40, 0.35, 0.35),  # Stable disease
#'   c(0.04, 0.12, 0.25, 0.30, 0.25),  # Partial response
#'   c(0.01, 0.03, 0.05, 0.10, 0.10)   # Complete response
#' )
#'
#' # Hepatotoxicity severity weights (clinical practice-based)
#' sev.weight <- c(0.0, 0.3, 1.0, 3.0)  # Strong penalty for Grade 3+
#' res.weight <- c(0.0, 0.2, 1.5, 3.5)  # Preference for objective responses
#'
#' # Moderate toxicity tolerance for targeted therapy
#' phi   <- 0.60  # Accept moderate weighted hepatotoxicity
#' delta <- 0.80  # Target meaningful weighted efficacy
#'
#' # Standard assessment windows for targeted therapy
#' tau.T   <- 42   # 6 weeks for LFT monitoring
#' tau.E   <- 56   # 8 weeks for response assessment
#' accrual <- 7    # Weekly enrollment
#'
#' results_tki <- gboinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   sev.weight = sev.weight, res.weight = res.weight,
#'   phi = phi, delta = delta,
#'   tau.T = tau.T, tau.E = tau.E, accrual = accrual,
#'   estpt.method = "obs.prob",
#'   obd.method = "utility.weighted",
#'   w1 = 0.4, w2 = 1.2,
#'   n.sim = 100
#' )
#'
#' # Display normalized equivalent scores (true values)
#' cat("True Normalized Equivalent Scores:\\n")
#' cat("nETS (Toxicity):", round(results_tki$nETS, 2), "\\n")
#' cat("nEES (Efficacy):", round(results_tki$nEES, 2), "\\n")
#'
#' # Example 2: Chemotherapy with neuropathy grading
#' # Scenario: Taxane with cumulative peripheral neuropathy
#'
#' n.dose      <- 4
#' size.cohort <- 6  # Larger cohorts for safety
#' n.cohort    <- 8
#'
#' # Neuropathy categories: None, Mild, Moderate, Severe
#' # Cumulative dose-dependent neuropathy
#' toxprob <- rbind(
#'   c(0.75, 0.55, 0.35, 0.20),  # No neuropathy
#'   c(0.20, 0.30, 0.35, 0.30),  # Mild neuropathy
#'   c(0.04, 0.12, 0.25, 0.35),  # Moderate neuropathy
#'   c(0.01, 0.03, 0.05, 0.15)   # Severe neuropathy
#' )
#'
#' # Response categories: No response, Minor, Major, Complete
#' effprob <- rbind(
#'   c(0.60, 0.40, 0.25, 0.20),  # No response
#'   c(0.30, 0.35, 0.35, 0.30),  # Minor response
#'   c(0.08, 0.20, 0.30, 0.35),  # Major response
#'   c(0.02, 0.05, 0.10, 0.15)   # Complete response
#' )
#'
#' # Neuropathy-specific weights (functional impact)
#' sev.weight <- c(0.0, 0.4, 1.2, 2.8)  # Severe neuropathy major QoL impact
#' res.weight <- c(0.0, 0.3, 1.8, 3.2)  # Complete response highly valued
#'
#' phi   <- 0.50  # Moderate neuropathy tolerance
#' delta <- 0.80  # Target substantial response
#'
#' tau.T   <- 84   # 12 weeks for neuropathy development
#' tau.E   <- 56   # 8 weeks for response assessment
#' accrual <- 14   # Bi-weekly enrollment
#'
#' results_chemo <- gboinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   sev.weight = sev.weight, res.weight = res.weight,
#'   phi = phi, delta = delta,
#'   tau.T = tau.T, tau.E = tau.E, accrual = accrual,
#'   estpt.method = "obs.prob",
#'   obd.method = "utility.truncated.linear",
#'   n.sim = 100
#' )
#'
#' # Compare with binary approximation
#' binary_tox <- 1 - toxprob[1,]  # Any neuropathy
#' binary_eff <- effprob[3,] + effprob[4,]  # Major + Complete response
#'
#' cat("Ordinal vs Binary Information:\\n")
#' cat("Binary toxicity rates:", round(binary_tox, 2), "\\n")
#' cat("Ordinal nETS scores:", round(results_chemo$nETS, 2), "\\n")
#' cat("Binary efficacy rates:", round(binary_eff, 2), "\\n")
#' cat("Ordinal nEES scores:", round(results_chemo$nEES, 2), "\\n")
#'
#' @note
#' \itemize{
#'   \item Matrix inputs require careful validation - rows must sum to 1.0
#'   \item Weight selection should involve clinical stakeholders and reflect patient preferences
#'   \item Normalized equivalent scores may not directly correspond to familiar probability scales
#' }
#'
#' @references
#' \itemize{
#'   \item Takeda, K., Morita, S., & Taguri, M. (2022). gBOIN-ET: The generalized
#'         Bayesian optimal interval design for optimal dose-finding accounting for
#'         ordinal graded efficacy and toxicity in early clinical trials.
#'         \emph{Biometrical Journal}, 64(7), 1178-1191.
#'   \item Yamaguchi, Y., Takeda, K., Yoshida, S., & Maruo, K. (2024). Optimal
#'         biological dose selection in dose-finding trials with model-assisted designs
#'         based on efficacy and toxicity: a simulation study. \emph{Journal of
#'         Biopharmaceutical Statistics}, 34(3), 379-393.
#' }
#'
#' @seealso
#' \code{\link{tite.gboinet}} for time-to-event version with ordinal outcomes,
#' \code{\link{boinet}} for binary outcome version,
#' \code{\link{obd.select}} for dose selection methods,
#' \code{\link{utility.weighted}}, \code{\link{utility.truncated.linear}},
#' \code{\link{utility.scoring}} for utility functions.
#'
#' @keywords clinical-trials ordinal-outcomes gBOIN-ET graded-endpoints dose-finding
#' @import Iso copula
#' @importFrom stats binomial dbinom pbeta pbinom rmultinom runif rexp
#' @export

gboinet <- function(
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

    obs.n   <- numeric(n.dose)
    obs.tox <- numeric(n.dose)
    obs.eff <- numeric(n.dose)
    pe      <- numeric(n.dose)
    pt      <- numeric(n.dose)

    t.enter    <- NULL
    t.decision <- 0

    curdose <- start.dose

    early.stop <- 0

    for(i in 1:nesc){
      dlab <- paste("Dose",curdose,sep="")
      obs.n[curdose] <- obs.n[curdose] + ncoh

      for(j in 1:ncoh){
        if(j==1){
          t.enter <- c(t.enter,t.decision)
        }else{
          if(gen.enroll.time=="uniform"){
            t.enter <- c(t.enter,t.enter[length(t.enter)]+runif(1,0,2*accrual))
          }else if(gen.enroll.time=="exponential"){
            t.enter <- c(t.enter,t.enter[length(t.enter)]+rexp(1,1/accrual))
          }
      }}
      t.decision <- t.enter[length(t.enter)]+max(tau.T,tau.E)

      time.te <- copula::rMvdc(ncoh,mv.ncop[[curdose]])

      event.T  <- as.numeric(time.te[,1]<=tau.T)
      grade    <- event.T*((1:ncat.T)%*%rmultinom(ncoh,1,efftoxp$toxp[-1,dlab]))+1
      ETS      <- apply(grade,2,function(x){return(sev.weight[x])})
      nETS     <- ETS/max(sev.weight)

      event.E  <- as.numeric(time.te[,2]<=tau.E)
      response <- event.E*((1:ncat.E)%*%rmultinom(ncoh,1,efftoxp$effp[-1,dlab]))+1
      EES      <- apply(response,2,function(x){return(res.weight[x])})
      nEES     <- EES/max(res.weight)

      obs.tox[curdose] <- obs.tox[curdose]+sum(nETS)
      pt[curdose] <- obs.tox[curdose]/obs.n[curdose]

      obs.eff[curdose] <- obs.eff[curdose]+sum(nEES)
      pe[curdose] <- obs.eff[curdose]/obs.n[curdose]

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

  class(result) <- "gboinet"
  result

}}



