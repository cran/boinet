
#' BOIN-ET: Bayesian Optimal Interval Design for Dose-Finding Based on Efficacy and Toxicity
#'
#' @description
#' Conducts simulation studies of the BOIN-ET (Bayesian Optimal Interval design for
#' dose finding based on both Efficacy and Toxicity outcomes) design to evaluate its
#' operating characteristics for identifying the optimal biological dose (OBD).
#' The BOIN-ET design extends the Bayesian optimal interval (BOIN) design, which
#' is nonparametric and thus does not require the assumption used in model-based
#' designs, in order to identify an optimal dose based on both efficacy and
#' toxicity outcomes.
#'
#' Unlike traditional phase I designs that focus solely on toxicity to find the maximum
#' tolerated dose (MTD), BOIN-ET addresses the modern need to balance safety and efficacy
#' for targeted therapies, immunotherapies, and biologics where the efficacy of
#' the drug does not always increase and could plateau at a lower dose.
#'
#' @details
#' \strong{Design Philosophy and Context:}
#'
#' One of the main purposes of a phase I dose-finding trial in oncology is to
#' identify an optimal dose (OD) that is both tolerable and has an indication of
#' therapeutic benefit for subjects in subsequent phase II and III trials.
#' Traditional dose-finding methods assume monotonic dose-toxicity and dose-efficacy
#' relationships, but this assumption often fails for modern cancer therapies.
#'
#' The BOIN-ET design is a **model-assisted** approach, not model-based, which makes it:
#' \itemize{
#'   \item **Robust**: No parametric assumptions about dose-response curves
#'   \item **Simple**: Pre-tabulated decision rules make implementation transparent
#'   \item **Flexible**: Accommodates various toxicity and efficacy scenarios
#'   \item **Clinically interpretable**: Decisions based on intuitive probability intervals
#' }
#'
#' \strong{Key Design Features:}
#'
#' **Dose Escalation/De-escalation Rules:**
#' The design uses pre-calculated boundaries (lambda1, lambda2, eta1) to make dosing decisions:
#' \itemize{
#'   \item **Escalate**: When toxicity <= lambda1 AND efficacy <= eta1
#'   \item **Stay**: When lambda1 < toxicity < lambda2 AND efficacy > eta1
#'   \item **De-escalate**: When toxicity >= lambda2
#'   \item **Efficacy-guided**: When lambda1 < toxicity < lambda2 AND efficacy <= eta1
#' }
#'
#' **Assessment Windows:**
#' Unlike time-to-event designs, standard BOIN-ET waits for complete outcome assessment
#' within specified windows (tau.T for toxicity, tau.E for efficacy) before making
#' dose decisions. This ensures data completeness but may slow accrual.
#'
#' **Early Stopping Rules:**
#' The design includes safety and futility stopping criteria based on posterior
#' probabilities exceeding pre-specified thresholds (stopping.prob.T, stopping.prob.E).
#'
#' **OBD Selection Methods:**
#' Multiple utility-based approaches are available for final dose selection:
#' \itemize{
#'   \item **utility.weighted**: Balances efficacy and toxicity with user-defined weights
#'   \item **utility.truncated.linear**: Uses piecewise linear utility functions
#'   \item **utility.scoring**: Discrete scoring system for outcome combinations
#'   \item **max.effprob**: Maximizes efficacy among acceptably safe doses
#' }
#'
#' \strong{When to Use BOIN-ET vs TITE-BOIN-ET:}
#'
#' **Use BOIN-ET when:**
#' \itemize{
#'   \item Outcomes occur relatively quickly (within assessment windows)
#'   \item Patient accrual is slow enough to wait for complete assessments
#'   \item You prefer simpler implementation without time-to-event modeling
#'   \item Historical precedent suggests minimal late-onset effects
#' }
#'
#' **Use TITE-BOIN-ET when:**
#' \itemize{
#'   \item Late-onset toxicity or efficacy is expected
#'   \item Rapid patient accrual is anticipated
#'   \item Trial duration is a critical constraint
#' }
#'
#' \strong{Simulation Output Interpretation:}
#'
#' The simulation results provide crucial operating characteristics:
#' \itemize{
#'   \item **prop.select**: Probability of correctly identifying each dose as OBD
#'   \item **n.patient**: Expected patient allocation across doses
#'   \item **prop.stop**: Probability of early termination without OBD selection
#'   \item **duration**: Expected trial duration
#' }
#'
#' @usage
#' boinet(
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
#'   probabilities for each dose level. Used for simulation scenarios.
#' @param effprob Numeric vector of length n.dose specifying the true efficacy
#'   probabilities for each dose level. Used for simulation scenarios.
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
#'   All toxicity evaluations must be completed within this period.
#' @param tau.E Numeric value specifying the efficacy assessment window in days.
#'   All efficacy evaluations must be completed within this period.
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
#' A list object of class "boinet" containing the following components:
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
#'   \item Design parameters must satisfy: phi1 < phi < phi2 and delta1 < delta
#'   \item Toxicity and efficacy probability vectors must have length n.dose
#'   \item The design waits for complete outcome assessment before dose decisions
#'   \item Consider TITE-BOIN-ET for trials with late-onset outcomes or rapid accrual
#'   \item Boundary values (lambda1, lambda2, eta1) are automatically optimized via grid search
#' }
#'
#' @examples
#' # Example 1: Basic BOIN-ET simulation for targeted therapy
#' # Scenario: Non-monotonic efficacy with moderate toxicity
#'
#' n.dose      <- 5
#' start.dose  <- 1
#' size.cohort <- 3
#' n.cohort    <- 15  # Total: 45 patients
#'
#' # Dose levels: 25mg, 50mg, 100mg, 200mg, 400mg
#' toxprob <- c(0.05, 0.10, 0.25, 0.40, 0.60)  # Monotonic toxicity
#' effprob <- c(0.20, 0.45, 0.70, 0.65, 0.55)  # Non-monotonic efficacy (plateau effect)
#'
#' # Conservative targets for targeted therapy
#' phi   <- 0.25  # 25% maximum toxicity
#' delta <- 0.60  # 60% target efficacy
#'
#' # Assessment windows
#' tau.T   <- 28  # 4 weeks for toxicity
#' tau.E   <- 84  # 12 weeks for efficacy
#' accrual <- 14  # 2 weeks between patients
#'
#' # Use observed probabilities and maximum efficacy method
#' estpt.method <- "obs.prob"
#' obd.method   <- "max.effprob"
#'
#' # Run simulation (small n.sim for example)
#' results <- boinet(
#'   n.dose = n.dose, start.dose = start.dose,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   phi = phi, delta = delta,
#'   tau.T = tau.T, tau.E = tau.E, accrual = accrual,
#'   estpt.method = estpt.method, obd.method = obd.method,
#'   n.sim = 100
#' )
#'
#' # Display key results
#' print(results$prop.select)  # OBD selection probabilities
#' print(results$n.patient)    # Patient allocation
#' print(results$duration)     # Expected trial duration
#'
#' # Example 2: Immunotherapy with utility-weighted OBD selection
#' # Higher tolerance for toxicity if efficacy is present
#'
#' n.dose      <- 4
#' size.cohort <- 6  # Larger cohorts for immunotherapy
#' n.cohort    <- 10
#'
#' # Immunotherapy dose-response pattern
#' toxprob <- c(0.10, 0.20, 0.35, 0.50)
#' effprob <- c(0.15, 0.30, 0.50, 0.45)  # Slight plateau at highest dose
#'
#' phi   <- 0.35  # Higher toxicity tolerance
#' delta <- 0.40  # Lower efficacy requirement
#'
#' tau.T   <- 42  # 6 weeks for immune-related toxicity
#' tau.E   <- 112 # 16 weeks for immune response
#' accrual <- 7   # Weekly accrual
#'
#' # Use utility-weighted method to balance toxicity-efficacy
#' results_utility <- boinet(
#'   n.dose = n.dose, start.dose = 1,
#'   size.cohort = size.cohort, n.cohort = n.cohort,
#'   toxprob = toxprob, effprob = effprob,
#'   phi = phi, delta = delta,
#'   tau.T = tau.T, tau.E = tau.E, accrual = accrual,
#'   estpt.method = "fp.logistic",  # Flexible dose-response modeling
#'   obd.method = "utility.weighted",
#'   w1 = 0.4,  # Moderate toxicity penalty
#'   w2 = 0.8,  # Additional penalty for high toxicity
#'   n.sim = 100
#' )
#'
#' # Display key results
#' print(results_utility$prop.select)  # OBD selection probabilities
#' print(results_utility$n.patient)    # Patient allocation
#' print(results_utility$duration)     # Expected trial duration
#'
#' @references
#' \itemize{
#'   \item Takeda, K., Taguri, M., & Morita, S. (2018). BOIN-ET: Bayesian optimal
#'         interval design for dose finding based on both efficacy and toxicity outcomes.
#'         \emph{Pharmaceutical Statistics}, 17(4), 383-395.
#'   \item Yamaguchi, Y., Takeda, K., Yoshida, S., & Maruo, K. (2024). Optimal
#'         biological dose selection in dose-finding trials with model-assisted designs
#'         based on efficacy and toxicity: a simulation study. \emph{Journal of
#'         Biopharmaceutical Statistics}, 34(3), 379-393.
#' }
#'
#' @seealso
#' \code{\link{tite.boinet}} for the time-to-event version that handles late-onset outcomes,
#' \code{\link{obd.select}} for optimal biological dose selection methods,
#' \code{\link{utility.weighted}}, \code{\link{utility.truncated.linear}},
#' \code{\link{utility.scoring}} for utility functions,
#' \code{\link{gridoptim}} for boundary optimization.
#'
#' @keywords clinical-trials dose-finding Bayesian optimal-biological-dose BOIN-ET
#' @export

boinet <- function(
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
      DLT     <- as.numeric(time.te[,1]<=tau.T)
      ORR     <- as.numeric(time.te[,2]<=tau.E)

      obs.tox[curdose] <- obs.tox[curdose]+sum(DLT)
      pt[curdose] <- obs.tox[curdose]/obs.n[curdose]

      obs.eff[curdose] <- obs.eff[curdose]+sum(ORR)
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

  class(result) <- "boinet"
  result

}}

