
#' TITE-BOIN-ET: Time-to-Event Bayesian Optimal Interval Design
#'
#' @description
#' Conducts simulation studies of the TITE-BOIN-ET (Time-to-Event Bayesian Optimal
#' Interval design to accelerate dose-finding based on both Efficacy and Toxicity outcomes)
#' design. This advanced extension of BOIN-ET addresses the practical challenges of
#' late-onset outcomes and rapid patient accrual in modern oncology trials by incorporating
#' time-to-event information and allowing continuous enrollment without waiting for
#' complete outcome assessment.
#'
#' The TITE-BOIN-ET design is particularly valuable for immunotherapy, targeted therapy,
#' and other novel agents where Late-onset toxicity is common and causes major
#' logistic difficulty for existing adaptive phase I trial designs, which require
#' the observance of toxicity early enough to apply dose-escalation rules for new patients.
#'
#' @details
#' \strong{Key Advantages:}
#'
#' **1. Continuous Accrual:**
#' Unlike standard BOIN-ET which waits for complete outcome assessment, TITE-BOIN-ET
#' allows continuous patient enrollment by utilizing both complete and pending (censored)
#' outcome data. This can significantly reduce trial duration.
#'
#' **2. Late-Onset Outcome Handling:**
#' The design explicitly models time-to-event outcomes, making it suitable for:
#' \itemize{
#'   \item Immune-related adverse events that may occur months after treatment
#'   \item Delayed efficacy responses common in immunotherapy
#'   \item Targeted agents with cumulative toxicity effects
#' }
#'
#' **3. Flexible Assessment Windows:**
#' Different assessment periods for toxicity (tau.T) and efficacy (tau.E) accommodate
#' the reality that safety and efficacy endpoints often have different time courses.
#'
#' **4. Correlated Outcomes:**
#' The design can model correlation between toxicity and efficacy through copula
#' functions, reflecting the biological relationship between these endpoints.
#'
#' \strong{Statistical Methodology:}
#'
#' **Time-to-Event Integration:**
#' The design uses a weighted likelihood approach where:
#' \itemize{
#'   \item Complete observations receive full weight
#'   \item Pending observations receive fractional weight based on follow-up time
#'   \item Weight = (observation time) / (assessment window)
#' }
#'
#' **Decision Algorithm:**
#' At each interim analysis, the design:
#' \enumerate{
#'   \item Updates outcome estimates using complete and pending data
#'   \item Applies the same decision boundaries as BOIN-ET (lambda1, lambda2, eta1)
#'   \item Makes dose escalation/de-escalation decisions
#'   \item Continues enrollment while maintaining safety monitoring
#' }
#'
#' **When to Choose TITE-BOIN-ET:**
#' \itemize{
#'   \item Expected late-onset toxicity
#'   \item Delayed efficacy assessment
#'   \item Rapid accrual
#'   \item Trial duration is a critical constraint
#' }
#'
#' **Consider Standard BOIN-ET When:**
#' \itemize{
#'   \item Outcomes occur within 2-4 weeks
#'   \item Slow accrual allows waiting for complete data
#'   \item Preference for simpler designs
#' }
#'
#' @usage
#' tite.boinet(
#'   n.dose, start.dose, size.cohort, n.cohort,
#'   toxprob, effprob,
#'   phi = 0.3, phi1 = phi*0.1, phi2 = phi*1.4,
#'   delta = 0.6, delta1 = delta*0.6,
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
#' @param toxprob Numeric vector of length n.dose specifying the true toxicity
#'   probabilities for each dose level. Used for simulation scenarios. Should
#'   reflect cumulative toxicity over tau.T period.
#' @param effprob Numeric vector of length n.dose specifying the true efficacy
#'   probabilities for each dose level. Used for simulation scenarios. Should
#'   reflect cumulative efficacy over tau.E period.
#' @param phi Numeric value between 0 and 1 specifying the target
#'   toxicity probability. Represents the maximum acceptable toxicity rate.
#'   Default is 0.3 (30%).
#' @param phi1 Numeric value specifying the highest toxicity
#'   probability that is deemed sub-therapeutic such that dose-escalation should
#'   be pursued. Doses with toxicity <= phi1 are considered under-dosed.
#'   Default is phi*0.1.
#' @param phi2 Numeric value specifying the lowest toxicity
#'   probability that is deemed overly toxic such that dose de-escalation is
#'   needed. Doses with toxicity >= phi2 are considered over-dosed. Default is phi*1.4.
#' @param delta Numeric value between 0 and 1 specifying the target
#'   efficacy probability. Represents the desired minimum efficacy rate. Default
#'   is 0.6 (60%).
#' @param delta1 Numeric value specifying the minimum probability
#'   deemed efficacious such that the dose levels with efficacy < delta1 are considered
#'   sub-therapeutic. Default is delta*0.6.
#' @param alpha.T1 Numeric value specifying the probability that a toxicity outcome occurs
#'   in the late half of the toxicity assessment window. Used for event time generation.
#'   Default is 0.5.
#' @param alpha.E1 Numeric value specifying the probability that an efficacy outcome
#'   occurs in the late half of the efficacy assessment window. Used for event
#'   time generation. Default is 0.5.
#' @param tau.T Numeric value specifying the toxicity assessment window in days.
#'   Should reflect the expected time course of relevant toxicities.
#' @param tau.E Numeric value specifying the efficacy assessment window in days.
#' @param te.corr Numeric value between -1 and 1 specifying the correlation between
#'   toxicity and efficacy, specified as Gaussian copula parameter. Default is 0.2
#'   (weak positive correlation).
#' @param gen.event.time Character string specifying the distribution for generating
#'   event times. Options are "weibull" (default) or "uniform". A bivariate
#'   Gaussian copula model is used to jointly generate the time to first toxicity
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
#'   termination threshold for toxicity. If P(toxicity > phi) > stopping.prob.T,
#'   the dose levels are eliminated from the investigation. Default is 0.95.
#' @param stopping.prob.E Numeric value between 0 and 1 specifying the early study
#'   termination threshold for efficacy. If P(efficacy < delta1) > stopping.prob.E,
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
#' A list object of class "tite.boinet" containing:
#' \item{toxprob}{True toxicity probabilities used in simulation.}
#' \item{effprob}{True efficacy probabilities used in simulation.}
#' \item{phi}{Target toxicity probability.}
#' \item{delta}{Target efficacy probability.}
#' \item{lambda1}{Lower toxicity decision boundary.}
#' \item{lambda2}{Upper toxicity decision boundary.}
#' \item{eta1}{Lower efficacy decision boundary.}
#' \item{tau.T}{Toxicity assessment window (days).}
#' \item{tau.E}{Efficacy assessment window (days).}
#' \item{accrual}{Accrual rate (days).}
#' \item{estpt.method}{Method used for efficacy probability estimation.}
#' \item{obd.method}{Method used for optimal biological dose selection.}
#' \item{n.patient}{Average number of patients treated at each dose level across simulations.}
#' \item{prop.select}{Percentage of simulations selecting each dose level as OBD.}
#' \item{prop.stop}{Percentage of simulations terminating early without OBD selection.}
#' \item{duration}{Expected trial duration in days.}
#'
#' @note
#' \itemize{
#'   \item Accrual rate significantly impacts design performance and trial duration
#'   \item Early stopping rules are critical for patient safety in TITE designs
#' }
#'
#' @examples
#' # Example 1: Immunotherapy trial with delayed immune-related toxicity
#' # Scenario: CAR-T therapy with cytokine release syndrome and delayed efficacy
#'
#' n.dose      <- 4  # Four dose levels
#' start.dose  <- 1
#' size.cohort <- 6  # Larger cohorts for immunotherapy
#' n.cohort    <- 8  # Total: 48 patients
#'
#' # CAR-T dose levels with delayed toxicity pattern
#' toxprob <- c(0.10, 0.25, 0.40, 0.55)  # Including delayed immune toxicity
#' effprob <- c(0.20, 0.50, 0.70, 0.75)  # Strong efficacy at higher doses
#'
#' # Immunotherapy-appropriate targets
#' phi   <- 0.35  # Higher toxicity tolerance
#' delta <- 0.60  # Target response rate
#'
#' # Extended assessment windows for immune effects
#' tau.T   <- 84   # 12 weeks for immune-related AEs
#' tau.E   <- 112  # 16 weeks for response assessment
#' accrual <- 7    # Weekly enrollment
#'
#' # Delayed toxicity/efficacy parameters
#' alpha.T1 <- 0.6  # Most toxicity in later period
#' alpha.E1 <- 0.7  # Most responses delayed
#' te.corr  <- 0.3  # Moderate positive correlation
#'
#' results_cart <- tite.boinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   phi = phi, delta = delta,
#'   alpha.T1 = alpha.T1, alpha.E1 = alpha.E1,
#'   tau.T = tau.T, tau.E = tau.E,
#'   te.corr = te.corr, accrual = accrual,
#'   estpt.method = "obs.prob",  # Conservative for small sample
#'   obd.method = "utility.weighted",
#'   w1 = 0.4, w2 = 1.2,  # Balanced approach with toxicity penalty
#'   n.sim = 40
#' )
#'
#' cat("Expected trial duration:", results_cart$duration, "days\\n")
#' cat("OBD selection probabilities:\\n")
#' print(results_cart$prop.select)
#'
#' # Example 2: Targeted therapy with rapid accrual
#' # Scenario: Tyrosine kinase inhibitor with fast enrollment
#'
#' n.dose      <- 5
#' size.cohort <- 3
#' n.cohort    <- 15  # 45 patients total
#'
#' # Targeted therapy dose-response
#' toxprob <- c(0.05, 0.12, 0.22, 0.35, 0.52)
#' effprob <- c(0.15, 0.35, 0.55, 0.65, 0.60)  # Plateau effect
#'
#' phi   <- 0.30
#' delta <- 0.50
#'
#' # Shorter windows for targeted therapy
#' tau.T   <- 28   # 4 weeks for acute toxicity
#' tau.E   <- 56   # 8 weeks for response
#' accrual <- 3    # Very rapid accrual (every 3 days)
#'
#' # More uniform timing
#' alpha.T1 <- 0.5
#' alpha.E1 <- 0.5
#' te.corr  <- 0.1  # Weak correlation
#'
#' results_tki <- tite.boinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   phi = phi, delta = delta,
#'   alpha.T1 = alpha.T1, alpha.E1 = alpha.E1,
#'   tau.T = tau.T, tau.E = tau.E,
#'   te.corr = te.corr, accrual = accrual,
#'   gen.event.time = "weibull",
#'   gen.enroll.time = "exponential",  # Variable enrollment
#'   estpt.method = "fp.logistic",  # Smooth modeling
#'   obd.method = "max.effprob",
#'   n.sim = 40
#' )
#'
#' # Compare duration to standard BOIN-ET (hypothetical)
#' standard_duration <- tau.E + (n.cohort * size.cohort * accrual)
#' cat("TITE duration:", results_tki$duration, "days\\n")
#' cat("Standard BOIN-ET would take ~", standard_duration, "days\\n")
#' cat("Time savings:", standard_duration - results_tki$duration, "days\\n")
#'
#' @references
#' \itemize{
#'   \item Takeda, K., Morita, S., & Taguri, M. (2020). TITE-BOIN-ET: Time-to-event
#'         Bayesian optimal interval design to accelerate dose-finding based on both
#'         efficacy and toxicity outcomes. \emph{Pharmaceutical Statistics}, 19(3), 335-349.
#'   \item Yamaguchi, Y., Takeda, K., Yoshida, S., & Maruo, K. (2024). Optimal
#'         biological dose selection in dose-finding trials with model-assisted designs
#'         based on efficacy and toxicity: a simulation study. \emph{Journal of
#'         Biopharmaceutical Statistics}, 34(3), 379-393.
#' }
#'
#' @seealso
#' \code{\link{boinet}} for the standard version without time-to-event modeling,
#' \code{\link{tite.gboinet}} for the generalized version with ordinal outcomes,
#' \code{\link{obd.select}} for optimal biological dose selection methods,
#' \code{\link{utility.weighted}}, \code{\link{utility.truncated.linear}},
#' \code{\link{utility.scoring}} for utility functions.
#'
#' @keywords clinical-trials dose-finding time-to-event TITE-BOIN-ET accelerated-design
#' @import Iso copula
#' @importFrom stats binomial dbinom pbeta pbinom rmultinom runif rexp
#' @export

tite.boinet <- function(
                 n.dose, start.dose, size.cohort, n.cohort,
                 toxprob, effprob,
                 phi=0.3, phi1=phi*0.1, phi2=phi*1.4, delta=0.6, delta1=delta*0.6,
                 alpha.T1=0.5, alpha.E1=0.5, tau.T, tau.E,
                 te.corr=0.2, gen.event.time="weibull",
                 accrual, gen.enroll.time="uniform",
                 stopping.npts=size.cohort*n.cohort,
                 stopping.prob.T=0.95, stopping.prob.E=0.99,
                 estpt.method = "obs.prob", obd.method = "max.effprob",
                 w1= 0.33, w2=1.09,
                 plow.ast=phi1, pupp.ast=phi2, qlow.ast=delta1/2, qupp.ast=delta,
                 psi00=40, psi11=60,
                 n.sim=1000, seed.sim=100)
{
  if(length(toxprob)!=n.dose){
    stop("Number of dose must be the same as the length of true toxicity probability.")

  }else if(length(effprob)!=n.dose){
    stop("Number of dose must be the same as the length of true efficacy probability.")

  }else if(!((phi1<phi)&(phi<phi2))){
    stop("Design parameters must satisfy a condition of phi1 < phi < phi2.")

  }else if(!(delta1<delta)){
    stop("Design parameters must satisfy a condition of delta1 < delta.")

  }else{

  dosen <- 1:n.dose
  dose  <- paste("Dose",dosen,sep="")

  toxp <- data.frame(t(toxprob))
  colnames(toxp) <- dose

  effp <- data.frame(t(effprob))
  colnames(effp) <- dose

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
      psi.T    <- efftoxp$toxp[i][[1]]
      zetta.T1 <- log(log(1-psi.T)/log(1-psi.T+alpha.T1*psi.T))/log(1/(1-alpha.T2))
      zetta.T2 <- tau.T/(-log(1-psi.T))^(1/zetta.T1)

      psi.E    <- efftoxp$effp[i][[1]]
      zetta.E1 <- log(log(1-psi.E)/log(1-psi.E+alpha.E1*psi.E))/log(1/(1-alpha.E2))
      zetta.E2 <- tau.E/(-log(1-psi.E))^(1/zetta.E1)

      mv.ncop <- append(mv.ncop,copula::mvdc(copula       = ncop,
                                             margins      = c("weibull","weibull"),
                                             paramMargins = list(list(shape=zetta.T1,scale=zetta.T2),
                                                                 list(shape=zetta.E1,scale=zetta.E2))))
    }

  }else if(gen.event.time=="uniform"){

    for(i in 1:n.dose){
      psi.T <- efftoxp$toxp[i][[1]]
      psi.E <- efftoxp$effp[i][[1]]

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
      DLT     <- as.numeric(time.te[,1]<=tau.T)
      ORR     <- as.numeric(time.te[,2]<=tau.E)

      tite.df <- rbind(tite.df,
                       data.frame(dose   = curdose,
                                  enter  = t.enter,
                                  endtox = t.enter+apply(as.matrix(1:ncoh),1,function(x){min(time.te[x,1],tau.T)}),
                                  dlt    = DLT,
                                  endeff = t.enter+apply(as.matrix(1:ncoh),1,function(x){min(time.te[x,2],tau.E)}),
                                  orr    = ORR))

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

          x.DLT  <- sum(compsub.T$dlt)
          n.DLT  <- x.DLT+sum(1-compsub.T$dlt)+sum(t.decision-pendsub.T$enter)/tau.T

          x.ORR  <- sum(compsub.E$orr)
          n.ORR  <- x.ORR+sum(1-compsub.E$orr)+sum(t.decision-pendsub.E$enter)/tau.E

          obs.tox[ds]   <- x.DLT
          obs.tox.n[ds] <- n.DLT
          pt[ds]        <- x.DLT/n.DLT

          obs.eff[ds]   <- x.ORR
          obs.eff.n[ds] <- n.ORR
          pe[ds]        <- x.ORR/n.ORR

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

  names(toxprob)      <- dose
  names(effprob)      <- dose
  names(phi)          <- "Target toxicity prob."
  names(delta)        <- "Target efficacy prob."
  names(lambda1)      <- "Lower toxicity boundary"
  names(lambda2)      <- "Upper toxicity boundary"
  names(eta1)         <- "Lower efficacy boundary"
  names(tau.T)        <- "Tox. assessment window (days)"
  names(tau.E)        <- "Eff. assessment window (days)"
  names(accrual)      <- "Accrual rate (days)"
  names(estpt.method) <- "Efficacy prob. estimation"
  names(obd.method)   <- "OBD selection"

  result <- list(toxprob      = toxprob,
                 effprob      = effprob,
                 phi          = phi,
                 delta        = delta,
                 lambda1      = lambda1,
                 lambda2      = lambda2,
                 eta1         = eta1,
                 tau.T        = tau.T,
                 tau.E        = tau.E,
                 accrual      = accrual,
                 estpt.method = estpt.method,
                 obd.method   = obd.method,
                 n.patient    = n.patient,
                 prop.select  = prop.select,
                 prop.stop    = prop.stop,
                 duration     = duration)

  class(result) <- "tite.boinet"
  result

}}




