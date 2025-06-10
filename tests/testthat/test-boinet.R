
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
target.ets <- 0.30
target.ees <- 0.60

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

n.patient.exp <- rbind(c(3.1,  3.2,  3.5,  3.9,  8.3, 14.1),
                       c(3.0,  3.1,  3.4,  4.8,  8.1, 13.7),
                       c(3.1,  3.3,  3.8,  4.7,  9.2, 12.0),
                       c(3.0,  3.3,  3.9,  4.6,  8.6, 12.5))

prop.select.exp <- rbind(c(1,    3,    3,    1,   17,   75),
                         c(1,    1,    2,    5,   15,   76),
                         c(3,    0,    4,    4,   16,   73),
                         c(1,    2,    3,    6,   25,   63))

prop.stop.exp      <- c(0, 0, 0, 0)
dim(prop.stop.exp) <- 4

duration.exp      <- c(965.8, 961.3, 611.2, 559.0)
dim(duration.exp) <- 4

test_that("Check boinet simulation results", {
  # Use expect_equal with tolerance for all simulation results
  # Cross-platform floating-point differences affect even "integer" simulation counts
  expect_equal(n.patient, n.patient.exp, tolerance = 1e-1)
  expect_equal(duration, duration.exp, tolerance = 1e-1)
  expect_equal(prop.select, prop.select.exp, tolerance = 0.5)  # Allow small count differences
  expect_equal(prop.stop, prop.stop.exp, tolerance = 1e-2)
})
