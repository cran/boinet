% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tite.gboinet.R
\name{tite.gboinet}
\alias{tite.gboinet}
\title{TITE-gBOIN-ET: Time-to-Event Generalized BOIN Design for Ordinal Graded Outcomes}
\usage{
tite.gboinet(
  n.dose, start.dose, size.cohort, n.cohort,
  toxprob, effprob, sev.weight, res.weight,
  phi, phi1 = phi*0.1, phi2 = phi*1.4,
  delta, delta1 = delta*0.6,
  alpha.T1 = 0.5, alpha.E1 = 0.5, tau.T, tau.E,
  te.corr = 0.2, gen.event.time = "weibull",
  accrual, gen.enroll.time = "uniform",
  stopping.npts = size.cohort*n.cohort,
  stopping.prob.T = 0.95, stopping.prob.E = 0.99,
  estpt.method = "obs.prob", obd.method = "max.effprob",
  w1 = 0.33, w2 = 1.09,
  plow.ast = phi1, pupp.ast = phi2,
  qlow.ast = delta1/2, qupp.ast = delta,
  psi00 = 40, psi11 = 60,
  n.sim = 1000, seed.sim = 100)
}
\arguments{
\item{n.dose}{Integer specifying the number of dose levels to investigate.}

\item{start.dose}{Integer specifying the starting dose level (1 = lowest dose).
Generally recommended to start at the lowest dose for safety.}

\item{size.cohort}{Integer specifying the number of patients per cohort.
Commonly 3 or 6 patients, with 3 being standard for early-phase trials.}

\item{n.cohort}{Integer specifying the maximum number of cohorts.
Total sample size = size.cohort*n.cohort.}

\item{toxprob}{Matrix (nrow = toxicity categories, ncol = n.dose) specifying
true toxicity probabilities. Each column must sum to 1.0. Rows represent
ordered toxicity levels from none to most severe.}

\item{effprob}{Matrix (nrow = efficacy categories, ncol = n.dose) specifying
true efficacy probabilities. Each column must sum to 1.0. Rows represent
ordered response levels from none to best response.}

\item{sev.weight}{Numeric vector of toxicity severity weights. Length must
equal nrow(toxprob). Should be non-decreasing and reflect clinical impact.
First element typically 0 (no toxicity). Example: c(0, 0.5, 1.0, 1.5) for
Grade 0 and 1, Grade 2, Grade 3, Grade 4.}

\item{res.weight}{Numeric vector of efficacy response weights. Length must
equal nrow(effprob). Should be non-decreasing and reflect clinical benefit.
First element typically 0 (no response). Example: c(0, 0.25, 1.0, 3.0) for
PD, SD, PR, CR.}

\item{phi}{Numeric target for normalized equivalent toxicity score (nETS).
Should be calibrated for weighted scores, not binary probabilities.}

\item{phi1}{Numeric lower boundary for nETS. Doses with nETS <= phi1 considered
under-dosed for toxicity. Default phi*0.1.}

\item{phi2}{Numeric upper boundary for nETS. Doses with nETS >= phi2 trigger
de-escalation. Default phi*1.4.}

\item{delta}{Numeric target for normalized equivalent efficacy score (nEES).
Should reflect desired level of clinical benefit.}

\item{delta1}{Numeric minimum threshold for nEES. Doses below this considered
sub-therapeutic. Default delta*0.6.}

\item{alpha.T1}{Numeric value specifying the probability that a toxicity outcome occurs
in the late half of the toxicity assessment window. Used for event time generation.
Default is 0.5.}

\item{alpha.E1}{Numeric value specifying the probability that an efficacy outcome
occurs in the late half of the efficacy assessment window. Used for event
time generation. Default is 0.5.}

\item{tau.T}{Numeric value specifying the toxicity assessment window in days.}

\item{tau.E}{Numeric value specifying the efficacy assessment window in days.}

\item{te.corr}{Numeric value between -1 and 1 specifying the correlation between
toxicity and efficacy, specified as Gaussian copula parameter. Default is 0.2
(weak positive correlation).}

\item{gen.event.time}{Character string specifying the distribution for generating
event times. Options are "weibull" (default) or "uniform". A bivariate
Gaussian copula model is used to jointly generate the time to first ordinal toxicity
and efficacy outcome, where the marginal distributions are set to Weibull
distribution when \code{gen.event.time="weibull"}, and uniform distribution when
\code{gen.event.time="uniform"}.}

\item{accrual}{Numeric value specifying the accrual rate (days), which is the
average number of days between patient enrollments. Lower values indicate
faster accrual.}

\item{gen.enroll.time}{Character string specifying the distribution for enrollment
times. Options are "uniform" (default) or "exponential". Uniform distribution
is used when \code{gen.enroll.time="uniform"}, and exponential distribution
is used when \code{gen.enroll.time="exponential"}.}

\item{stopping.npts}{Integer specifying the maximum number of patients per dose
for early study termination. If the number of patients at the current dose
reaches this criteria, the study stops the enrollment and is terminated.
Default is size.cohort*n.cohort.}

\item{stopping.prob.T}{Numeric value between 0 and 1 specifying the early study
termination threshold for toxicity. If P(nETS > phi) > stopping.prob.T,
the dose levels are eliminated from the investigation. Default is 0.95.}

\item{stopping.prob.E}{Numeric value between 0 and 1 specifying the early study
termination threshold for efficacy. If P(nEES < delta1) > stopping.prob.E,
the dose levels are eliminated from the investigation. Default is 0.99.}

\item{estpt.method}{Character string specifying the method for estimating efficacy
probabilities. Options: "obs.prob" (observed efficacy probabilitiesrates),
or "fp.logistic" (fractional polynomial). Default is "obs.prob".}

\item{obd.method}{Character string specifying the method for OBD selection.
Options: "utility.weighted", "utility.truncated.linear", "utility.scoring",
or "max.effprob" (default).}

\item{w1}{Numeric value specifying the weight for toxicity-efficacy trade-off
in "utility.weighted" method. Default is 0.33.}

\item{w2}{Numeric value specifying the penalty weight for toxic doses in
"utility.weighted" method. Default is 1.09.}

\item{plow.ast}{Numeric value specifying the lower toxicity threshold for
"utility.truncated.linear" method. Default is phi1.}

\item{pupp.ast}{Numeric value specifying the upper toxicity threshold for
"utility.truncated.linear" method. Default is phi2.}

\item{qlow.ast}{Numeric value specifying the lower efficacy threshold for
"utility.truncated.linear" method. Default is delta1/2.}

\item{qupp.ast}{Numeric value specifying the upper efficacy threshold for
"utility.truncated.linear" method. Default is delta.}

\item{psi00}{Numeric value specifying the utility score for (toxicity=no, efficacy=no)
in "utility.scoring" method. Default is 40.}

\item{psi11}{Numeric value specifying the utility score for (toxicity=yes, efficacy=yes)
in "utility.scoring" method. Default is 60.}

\item{n.sim}{Integer specifying the number of simulated trials. Default is 1000.
Higher values provide more stable operating characteristics.}

\item{seed.sim}{Integer specifying the random seed for reproducible results.
Default is 100.}
}
\value{
A list object of class "tite.gboinet" containing the following components:
\item{toxprob}{True toxicity probability matrix used in simulation.}
\item{effprob}{True efficacy probability matrix used in simulation.}
\item{nETS}{True normalized equivalent toxicity scores by dose level.}
\item{nEES}{True normalized equivalent efficacy scores by dose level.}
\item{phi}{Target normalized equivalent toxicity scores.}
\item{delta}{Target normalized equivalent efficacy scores.}
\item{lambda1}{Lower toxicity decision boundary.}
\item{lambda2}{Upper toxicity decision boundary.}
\item{eta1}{Lower efficacy decision boundary.}
\item{tau.T}{Toxicity assessment window (days).}
\item{tau.E}{Efficacy assessment window (days).}
\item{accrual}{Accrual rate (days).}
\item{ncat.T}{Number of ordinal toxicity outcome categories.}
\item{ncat.E}{Number of ordinal efficacy outcome categories.}
\item{estpt.method}{Method used for efficacy probability estimation.}
\item{obd.method}{Method used for optimal biological dose selection.}
\item{n.patient}{Average number of patients treated at each dose level across simulations.}
\item{prop.select}{Percentage of simulations selecting each dose level as OBD.}
\item{prop.stop}{Percentage of simulations terminating early without OBD selection.}
\item{duration}{Expected trial duration in days.}
}
\description{
Conducts simulation studies of the TITE-gBOIN-ET (Time-to-Event generalized
Bayesian Optimal Interval design to accelerate dose-finding accounting for ordinal
graded Efficacy and Toxicity outcomes) design. This advanced extension incorporates
both time-to-event modeling and ordinal (graded) outcome assessment, making it
suitable for modern oncology trials where both the severity of toxicity and the
degree of efficacy response are clinically meaningful.

The design addresses the reality that clinical outcomes are rarely binary. For
example, toxicity may range from mild (Grade 1) to life-threatening (Grade 4),
while efficacy can span from no response to complete response. By utilizing this
additional information, TITE-gBOIN-ET can make more informed dose selection
decisions while maintaining the advantages of time-to-event modeling for
delayed outcomes.
}
\details{
\strong{Key Advantages:}

\strong{1. Ordinal Outcome Modeling:}
Instead of binary toxicity/efficacy, the design uses:
\itemize{
\item \strong{Toxicity categories}: e.g., None, Mild, Moderate, Severe
\item \strong{Efficacy categories}: e.g., No Response, Partial Response, Complete Response
\item \strong{Weighted scoring}: Different severity levels receive different weights
\item \strong{Normalized equivalent scores}: nETS (toxicity) and nEES (efficacy)
}

\strong{2. Enhanced Information Utilization:}
The design captures more granular clinical information by considering:
\itemize{
\item Grade 2 toxicity as different from Grade 4 toxicity
\item Partial response as different from complete response
\item Clinically meaningful gradations within traditional binary endpoints
}

\strong{3. Flexible Weighting Schemes:}
Users can specify custom weights reflecting clinical importance:
\itemize{
\item \strong{sev.weight}: Toxicity severity weights (e.g., 0, 0.5, 1.0, 1.5)
\item \strong{res.weight}: Efficacy response weights (e.g., 0, 0.25, 1.0, 3.0)
}

\strong{Statistical Methodology:}

\strong{Equivalent Toxicity/Efficacy Scores:}

The design converts ordinal outcomes to continuous scores:
\itemize{
\item \strong{ETS (Equivalent Toxicity Score)}: Weighted sum of toxicity categories
\item \strong{EES (Equivalent Efficacy Score)}: Weighted sum of efficacy categories
\item \strong{Normalization}: Scores divided by maximum possible weight (nETS, nEES)
\item \strong{Decision making}: Uses normalized scores with same boundaries as binary BOIN-ET
}

\strong{Time-to-Event Integration:}
Combines ordinal scoring with time-to-event methodology:
\itemize{
\item Events can occur at different times within assessment windows
\item Partial information from censored observations
}

\strong{Matrix Input Structure:}
Probability matrices define outcome distributions:
\itemize{
\item \strong{toxprob}: Matrix where rows = toxicity categories, columns = doses
\item \strong{effprob}: Matrix where rows = efficacy categories, columns = doses
\item Row sums should equal 1 (probability distributions)
\item Allows complex, realistic outcome scenarios
}
}
\note{
\itemize{
\item Probability matrices must have rows summing to 1.0 for each dose
\item Weight vectors must have same length as corresponding outcome categories
\item Normalized scores may require different target values than binary probabilities
}
}
\examples{
# Example: CAR-T therapy with graded CRS and response levels
# Scenario: 4 dose levels with detailed toxicity/efficacy grading

n.dose      <- 4
start.dose  <- 1
size.cohort <- 6  # Larger cohorts for complex outcomes
n.cohort    <- 8

# Toxicity categories: None, Mild CRS, Moderate CRS, Severe CRS
# Higher doses increase severe CRS probability
toxprob <- rbind(
  c(0.85, 0.70, 0.50, 0.30),  # No CRS
  c(0.10, 0.20, 0.25, 0.25),  # Mild CRS
  c(0.04, 0.08, 0.20, 0.30),  # Moderate CRS
  c(0.01, 0.02, 0.05, 0.15)   # Severe CRS
)

# Efficacy categories: No response, Partial remission, Complete remission, MRD-negative
# Strong dose-response relationship
effprob <- rbind(
  c(0.70, 0.45, 0.25, 0.15),  # No response
  c(0.25, 0.35, 0.35, 0.25),  # Partial remission
  c(0.04, 0.15, 0.30, 0.40),  # Complete remission
  c(0.01, 0.05, 0.10, 0.20)   # MRD-negative CR
)

# Clinical severity weights
sev.weight <- c(0.0, 0.3, 1.0, 2.5)    # Severe CRS heavily weighted
res.weight <- c(0.0, 0.5, 2.0, 4.0)    # Strong preference for deep responses

# CAR-T appropriate parameters
phi   <- 0.40  # Accept moderate weighted toxicity
delta <- 0.80  # Target substantial weighted efficacy

# Extended assessment for immune effects
tau.T   <- 84   # 12 weeks for CRS resolution
tau.E   <- 168  # 24 weeks for response assessment
accrual <- 14   # Bi-weekly enrollment

# Delayed and correlated outcomes
alpha.T1 <- 0.4  # Earlier CRS onset
alpha.E1 <- 0.8  # Much delayed responses
te.corr  <- 0.4  # Moderate positive correlation

results_cart <- tite.gboinet(
  n.dose = n.dose, start.dose = start.dose,
  size.cohort = size.cohort, n.cohort = n.cohort,
  toxprob = toxprob, effprob = effprob,
  sev.weight = sev.weight, res.weight = res.weight,
  phi = phi, delta = delta,
  alpha.T1 = alpha.T1, alpha.E1 = alpha.E1,
  tau.T = tau.T, tau.E = tau.E,
  te.corr = te.corr, accrual = accrual,
  estpt.method = "obs.prob",
  obd.method = "utility.weighted",
  w1 = 0.5, w2 = 1.5,  # Balance with strong toxicity penalty
  n.sim = 40
)

# Display normalized equivalent scores
cat("Normalized Equivalent Toxicity Scores (nETS):\\\\n")
print(results_cart$nETS)
cat("Normalized Equivalent Efficacy Scores (nEES):\\\\n")
print(results_cart$nEES)

cat("OBD Selection Probabilities:\\\\n")
print(results_cart$prop.select)

}
\references{
\itemize{
\item Takeda, K., Yamaguchi, Y., Taguri, M., & Morita, S. (2023). TITE-gBOIN-ET:
Time-to-event generalized Bayesian optimal interval design to accelerate
dose-finding accounting for ordinal graded efficacy and toxicity outcomes.
\emph{Biometrical Journal}, 65(7), e2200265.
\item Yamaguchi, Y., Takeda, K., Yoshida, S., & Maruo, K. (2024). Optimal
biological dose selection in dose-finding trials with model-assisted designs
based on efficacy and toxicity: a simulation study. \emph{Journal of
Biopharmaceutical Statistics}, 34(3), 379-393.
}
}
\seealso{
\code{\link{tite.boinet}} for binary outcome version,
\code{\link{gboinet}} for non-time-to-event ordinal version,
\code{\link{obd.select}} for dose selection methods,
\code{\link{utility.weighted}}, \code{\link{utility.truncated.linear}},
\code{\link{utility.scoring}} for utility functions.
}
\keyword{TITE-gBOIN-ET}
\keyword{clinical-trials}
\keyword{graded-outcomes}
\keyword{ordinal-outcomes}
\keyword{time-to-event}
