
toxprob.g <- rbind(c(0.94,0.87,0.79,0.68,0.62,0.50),
                   c(0.05,0.10,0.15,0.20,0.20,0.20),
                   c(0.01,0.03,0.05,0.10,0.15,0.25),
                   c(0.00,0.00,0.01,0.02,0.03,0.05))
toxprob   <- apply(toxprob.g[3:4,],2,sum)

effprob.g <- rbind(c(0.64,0.52,0.45,0.35,0.20,0.05),
                   c(0.30,0.40,0.40,0.40,0.40,0.15),
                   c(0.05,0.05,0.10,0.15,0.20,0.35),
                   c(0.01,0.03,0.05,0.10,0.20,0.45))
effprob   <- apply(effprob.g[3:4,],2,sum)

sev.weight <- c(0.00,0.50,1.00,1.50)
res.weight <- c(0.00,0.25,1.00,3.00)

n.dose      <- 6
start.dose  <- 1
size.cohort <- 3
n.cohort    <- 12

target.dlt <- 0.33
target.orr <- 0.70
target.ets <- 0.313
target.ees <- 0.583

tau.T <- 30
tau.E <- 60

te.corr <- 0.0

accrual <- 10

estpt.method <- "obs.prob"
obd.method   <- "max.effprob"

n.patient   <- array(0,dim=c(4,n.dose))
prop.select <- array(0,dim=c(4,n.dose))
prop.stop   <- array(0,dim=c(4))
duration    <- array(0,dim=c(4))

for(m in 1:4){
  
  if(m==1){
    res <- boinet(
      n.dose=n.dose, start.dose=start.dose, size.cohort=size.cohort, n.cohort=n.cohort,
      toxprob=toxprob, effprob=effprob,
      phi=target.dlt, delta=target.orr, tau.T=tau.T, tau.E=tau.E,
      te.corr=te.corr, accrual=accrual, estpt.method=estpt.method, obd.method=obd.method,
      n.sim=100, seed.sim=66)
    
  }else if(m==2){
    res <- gboinet(
      n.dose=n.dose, start.dose=start.dose, size.cohort=size.cohort, n.cohort=n.cohort,
      toxprob=toxprob.g, effprob=effprob.g, sev.weight=sev.weight, res.weight=res.weight,
      phi=target.ets, delta=target.ees, tau.T=tau.T, tau.E=tau.E,
      te.corr=te.corr, accrual=accrual, estpt.method=estpt.method, obd.method=obd.method,
      n.sim=100, seed.sim=66)
    
  }else if(m==3){
    res <- tite.boinet(
      n.dose=n.dose, start.dose=start.dose, size.cohort=size.cohort, n.cohort=n.cohort,
      toxprob=toxprob, effprob=effprob,
      phi=target.dlt, delta=target.orr, tau.T=tau.T, tau.E=tau.E,
      te.corr=te.corr, accrual=accrual, estpt.method=estpt.method, obd.method=obd.method,
      n.sim=100, seed.sim=66)
    
  }else if(m==4){
    res <- tite.gboinet(
      n.dose=n.dose, start.dose=start.dose, size.cohort=size.cohort, n.cohort=n.cohort,
      toxprob=toxprob.g, effprob=effprob.g, sev.weight=sev.weight, res.weight=res.weight,
      phi=target.ets, delta=target.ees, tau.T=tau.T, tau.E=tau.E,
      te.corr=te.corr, accrual=accrual, estpt.method=estpt.method, obd.method=obd.method,
      n.sim=100, seed.sim=66)
  }
  
  n.patient[m,]   <- res$n.patient
  prop.select[m,] <- res$prop.select
  prop.stop[m]    <- res$prop.stop
  duration[m]     <- res$duration
  
}

n.patient.exp <- rbind(c(3.7,  3.9,  4.2,  4.9,  7.3, 12.0),
                       c(3.7,  4.3,  4.7,  4.9,  6.8, 11.5),
                       c(3.4,  3.8,  4.7,  5.8,  7.2, 11.1),
                       c(3.9,  4.7,  5.1,  5.7,  7.0,  9.6))

prop.select.exp <- rbind(c(2,    1,    2,    6,   24,   65),
                         c(0,    0,    2,   10,   20,   68),
                         c(2,    2,    6,   10,   17,   63),
                         c(1,    2,    3,    6,   26,   62))

prop.stop.exp      <- c(0, 0, 0, 0)
dim(prop.stop.exp) <- 4

duration.exp      <- c(958.6, 961.5, 612.2, 557.0)
dim(duration.exp) <- 4

test_that("Check boinet simulation results", {
  expect_identical(n.patient,  n.patient.exp)
  expect_identical(prop.select,prop.select.exp)
  expect_identical(prop.stop,  prop.stop.exp)
  expect_identical(duration,   duration.exp)
})
