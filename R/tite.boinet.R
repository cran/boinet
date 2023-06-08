
#' Conducting simulation study of TITE-BOIN-ET design
#'
#' Time-to-event Bayesian optimal interval design to accelerate dose-finding
#' based on both efficacy and toxicity outcomes (TITE-BOIN-ET design) is
#' implemented under a scenario
#' specified. Operating characteristics of the design are summarized by the
#' percentage of times that each dose level was selected as optimal biological
#' dose and the average number of patients who were treated at each dose level.
#' @usage
#' tite.boinet(
#'   n.dose, start.dose, size.cohort, n.cohort,
#'   toxprob, effprob,
#'   phi=0.3, phi1=phi*0.1, phi2=phi*1.4, delta=0.6, delta1=delta*0.6,
#'   alpha.T1=0.5, alpha.E1=0.5, tau.T, tau.E,
#'   te.corr=0.2, gen.event.time="weibull",
#'   accrual, gen.enroll.time="uniform",
#'   stopping.npts=size.cohort*n.cohort,
#'   stopping.prob.T=0.95, stopping.prob.E=0.99,
#'   estpt.method, obd.method,
#'   w1= 0.33, w2=1.09,
#'   plow.ast=phi1, pupp.ast=phi2, qlow.ast=delta1/2, qupp.ast=delta,
#'   psi00=40, psi11=60,
#'   n.sim=1000, seed.sim=100)
#' @param n.dose Number of dose.
#' @param start.dose Starting dose. The lowest dose is generally recommended.
#' @param size.cohort Cohort size.
#' @param n.cohort Number of cohort.
#' @param toxprob Vector of true toxicity probability.
#' @param effprob Vector of true efficacy probability.
#' @param phi Target toxicity probability. The default value is
#' \code{phi=0.3}.
#' @param phi1 Highest toxicity probability that is deemed sub-therapeutic such
#' that dose-escalation should be pursued. The default value is
#' \code{phi1=phi*0.1}.
#' @param phi2 Lowest toxicity probability that is deemed overly toxic such that
#' dose de-escalation is needed. The default value is \code{phi2=phi*1.4}.
#' @param delta Target efficacy probability. The default value is
#' \code{delta=0.6}.
#' @param delta1 Minimum probability deemed efficacious such that the dose
#' levels with less than delta1 are considered sub-therapeutic.
#' The default value is \code{delta1=delta*0.6}.
#' @param alpha.T1 Probability that toxicity event occurs in the late half of
#' toxicity assessment window. The default value is \code{alpha.T1=0.5}.
#' @param alpha.E1 Probability that efficacy event occurs in the late half of
#' assessment window. The default value is \code{alpha.E1=0.5}.
#' @param tau.T Toxicity assessment windows (days).
#' @param tau.E Efficacy assessment windows (days).
#' @param te.corr Correlation between toxicity and efficacy probability,
#' specified as Gaussian copula parameter. The default value is
#' \code{te.corr=0.2}.
#' @param gen.event.time Method to generate the time to first toxicity and
#' efficacy outcome. Weibull distribution is used when
#' \code{gen.event.time="weibull"}. Uniform distribution is used when
#' \code{gen.event.time="uniform"}. The default value is
#' \code{gen.event.time="weibull"}.
#' @param accrual Accrual rate (days) (average number of days necessary to
#' enroll one patient).
#' @param gen.enroll.time Method to generate enrollment time. Uniform
#' distribution is used when \code{gen.enroll.time="uniform"}. Exponential
#' distribution is used when \code{gen.enroll.time="exponential"}. The default
#' value is \code{gen.enroll.time="uniform"}.
#' @param stopping.npts Early study termination criteria for the number of
#' patients. If the number of patients at the current dose reaches this
#' criteria, the study is terminated. The default value is
#' \code{stopping.npts=size.cohort*n.cohort}.
#' @param stopping.prob.T Early study termination criteria for toxicity,
#' taking a value between 0 and 1. If the posterior probability that toxicity
#' outcome is less than the target toxicity probability (\code{phi}) is larger than
#' this criteria, the dose levels are eliminated from the study. The default
#' value is \code{stopping.prob.T=0.95}.
#' @param stopping.prob.E Early study termination criteria for efficacy,
#' taking a value between 0 and 1. If the posterior probability that efficacy
#' outcome is less than the minimum efficacy probability (\code{delta1}) is larger
#' than this criteria, the dose levels are eliminated from the study.
#' The default value is \code{stopping.prob.E=0.99}.
#' @param estpt.method Method to estimate the efficacy probability. Fractional
#' polynomial logistic regression is used when \code{estpt.method="fp.logistic"}.
#' Model averaging of multiple unimodal isotopic regression is used when
#' \code{estpt.method="multi.iso"}. Observed efficacy probability is used when
#' \code{estpt.method="obs.prob"}.
#' @param obd.method Method to select the optimal biological dose. Utility
#' defined by weighted function is used when \code{obd.method="utility.weighted"}.
#' Utility defined by truncated linear function is used when
#' \code{obd.method="utility.truncated.linear"}. Utility defined by scoring is
#' used when \code{obd.method="utility.scoring"}. Highest estimated efficacy
#' probability is used when \code{obd.method="max.effprob"}.
#' @param w1 Weight for toxicity-efficacy trade-off in utility defined by
#' weighted function. This must be specified when using
#' \code{obd.method="utility.weighted"}. The default value is \code{w1=0.33}.
#' @param w2 Weight for penalty imposed on toxic doses in utility defined by
#' weighted function. This must be specified when using
#' \code{obd.method="utility.weighted"}. The default value is \code{w2=1.09}.
#' @param plow.ast Lower threshold of toxicity linear truncated function. This
#' must be specified when using \code{obd.method="utility.truncated.linear"}.
#' The default value is \code{plow.ast=phi1}.
#' @param pupp.ast Upper threshold of toxicity linear truncated function. This
#' must be specified when using \code{obd.method="utility.truncated.linear"}.
#' The default value is \code{pupp.ast=phi2}.
#' @param qlow.ast Lower threshold of efficacy linear truncated function. This
#' must be specified when using \code{obd.method="utility.truncated.linear"}.
#' The default value is \code{qlow.ast=delta1/2}.
#' @param qupp.ast Upper threshold of efficacy linear truncated function. This
#' must be specified when using \code{obd.method="utility.truncated.linear"}.
#' The default value is \code{qupp.ast=delta}.
#' @param psi00 Score for toxicity=no and efficacy=no in utility defined by
#' scoring. This must be specified when using \code{obd.method="utility.scoring"}.
#' The default value is \code{psi00=40}.
#' @param psi11 Score for toxicity=yes and efficacy=yes in utility defined by
#' scoring. This must be specified when using \code{obd.method="utility.scoring"}.
#' The default value is \code{psi11=60}.
#' @param n.sim Number of simulated trial. The default value is
#' \code{n.sim=1000}.
#' @param seed.sim Seed for random number generator. The default value is
#' \code{seed.sim=100}.
#' @details The \code{tite.boinet} is a function which generates the operating
#' characteristics of the time-to-event Bayesian optimal interval design to
#' accelerate dose-finding based on both efficacy and toxicity outcomes
#' (TITE-BOIN-ET design) by a simulation study. Users can specify a
#' variety of study settings to simulate studies, and choose methods to estimate
#' the efficacy probability and to select the optimal biological dose. The
#' operating characteristics of the design are summarized by the percentage of
#' times that each dose level was selected as optimal biological dose and the
#' average number of patients who were treated at each dose level. The
#' percentage of times that the study was terminated and the expected study
#' duration are also provided.
#' @return
#' The \code{tite.boinet} returns a list containing the following components:
#' \item{toxprob}{True toxicity probability.}
#' \item{effprob}{True efficacy probability.}
#' \item{phi}{Target toxicity probability.}
#' \item{delta}{Target efficacy probability.}
#' \item{lambda1}{Lower toxicity boundary in dose escalation/de-escalation.}
#' \item{lambda2}{Upper toxicity boundary in dose escalation/de-escalation.}
#' \item{eta1}{Lower efficacy boundary in dose escalation/de-escalation.}
#' \item{tau.T}{Toxicity assessment windows (days).}
#' \item{tau.E}{Efficacy assessment windows (days).}
#' \item{accrual}{Accrual rate (days) (average number of days necessary to
#' enroll one patient).}
#' \item{estpt.method}{Method to estimate the efficacy probability.}
#' \item{obd.method}{Method to select the optimal biological dose.}
#' \item{n.patient}{Average number of patients who were treated at each dose
#' level}
#' \item{prop.select}{Percentage of times that each dose level was selected as
#' optimal biological dose.}
#' \item{prop.stop}{Percentage of times that the study was terminated.}
#' \item{duration}{Expected study duration (days)}
#' @references
#' Takeda K, Morita S, Taguri M. TITE-BOIN-ET: Time-to-event Bayesian optimal
#' interval design to accelerate dose-finding based on both efficacy and
#' toxicity outcomes. *Pharmaceutical Statistics* 2020; 19(3):335-349.
#'
#' Yamaguchi Y, Takeda K, Yoshida S, Maruo K. Optimal biological dose selection
#' in dose-finding trials with model-assisted designs based on efficacy and
#' toxicity: a simulation study. *Journal of Biopharmaceutical Statistics* 2023;
#' doi: 10.1080/10543406.2023.2202259.
#' @examples
#' n.dose      <- 6
#' start.dose  <- 1
#' size.cohort <- 3
#' n.cohort    <- 12
#'
#' toxprob <- c(0.01,0.03,0.06,0.12,0.18,0.30)
#' effprob <- c(0.06,0.08,0.15,0.25,0.40,0.80)
#'
#' phi   <- 0.33
#' delta <- 0.70
#'
#' tau.T   <- 30
#' tau.E   <- 45
#' accrual <- 10
#'
#' estpt.method <- "obs.prob"
#' obd.method   <- "max.effprob"
#'
#' n.sim <- 10
#'
#' tite.boinet(
#'   n.dose=n.dose, start.dose=start.dose,
#'   size.cohort=size.cohort, n.cohort=n.cohort,
#'   toxprob=toxprob, effprob=effprob,
#'   phi=phi, delta=delta,
#'   tau.T=tau.T, tau.E=tau.E, accrual=accrual,
#'   estpt.method=estpt.method, obd.method=obd.method,
#'   n.sim=n.sim)
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
                 estpt.method, obd.method,
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
          three   <- c(curdose-1,curdose)
          maxpe   <- max(pe[three])
          nxtdose <- sample(dosen[which((pe==maxpe)&(is.element(dosen,three)))],1)

        }else if(obs.n[curdose+1]==0){
          nxtdose <- curdose+1

        }else if(curdose==1){
          three   <- c(curdose,curdose+1)
          maxpe   <- max(pe[three])
          nxtdose <- sample(dosen[which((pe==maxpe)&(is.element(dosen,three)))],1)

        }else{
          three   <- c(curdose-1,curdose,curdose+1)
          maxpe   <- max(pe[three])
          nxtdose <- sample(dosen[which((pe==maxpe)&(is.element(dosen,three)))],1)
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
        break

      }else if(sum(obs.n>=stopping.npts)>0){
        break

      }else{

        if(nxtdose==0){
          if(admflg[1]){
            curdose <- 1
          }else{
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

    if(sum(obs.n)<nmax){

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
  names(prop.stop) <- "Stop %"

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




