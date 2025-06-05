
#' Weighted Utility Function for Toxicity-Efficacy Trade-off
#'
#' @description
#' Calculates utility scores for dose selection based on a weighted function that
#' balances efficacy benefits against toxicity costs. This utility function provides
#' a linear trade-off approach with an additional penalty for doses exceeding a
#' toxicity threshold, making it particularly suitable for dose-finding scenarios
#' where both the overall toxicity rate and severe toxicity cases need to be
#' appropriately penalized.
#'
#' The weighted utility approach is intuitive for clinicians as it directly reflects
#' the clinical decision-making process: maximize efficacy while minimizing toxicity,
#' with extra caution for doses that exceed acceptable toxicity levels.
#'
#' @details
#' \strong{Mathematical Formulation:}
#'
#' The utility function is defined as:
#' \deqn{U(p_T, p_E) = p_E - w_1 \cdot p_T - w_2 \cdot p_T \cdot I(p_T > \phi_2)}
#'
#' Where:
#' \itemize{
#'   \item \eqn{p_E}: Efficacy probability (benefit component)
#'   \item \eqn{p_T}: Toxicity probability (cost component)
#'   \item \eqn{w_1}: Basic toxicity penalty weight
#'   \item \eqn{w_2}: Additional penalty for excessive toxicity
#'   \item \eqn{\phi_2}: Toxicity threshold (tox.upper)
#'   \item \eqn{I(\cdot)}: Indicator function (1 if condition true, 0 otherwise)
#' }
#'
#' \strong{Interpretation of Components:}
#'
#' **Base Efficacy Term (\eqn{p_E}):**
#' \itemize{
#'   \item Represents the direct clinical benefit
#'   \item Higher efficacy increases utility linearly
#'   \item Assumes all efficacy is equally valuable
#' }
#'
#' **Linear Toxicity Penalty (\eqn{w_1 \cdot p_T}):**
#' \itemize{
#'   \item Constant penalty per unit increase in toxicity
#'   \item Reflects baseline toxicity aversion
#'   \item Applied regardless of toxicity level
#' }
#'
#' **Threshold Toxicity Penalty (\eqn{w_2 \cdot p_T \cdot I(p_T > \phi_2)}):**
#' \itemize{
#'   \item Additional penalty only when toxicity exceeds threshold
#'   \item Models clinical concern about "unacceptable" toxicity levels
#'   \item Creates discontinuity in utility function at threshold
#' }
#'
#' \strong{Comparison with Other Utility Functions:}
#'
#' **vs. Truncated Linear:**
#' \itemize{
#'   \item Simpler parameter structure (3 vs 4 thresholds)
#'   \item Less flexible but more interpretable
#'   \item Better for scenarios with clear toxicity limits
#' }
#'
#' **vs. Scoring:**
#' \itemize{
#'   \item Continuous rather than discrete outcomes
#'   \item More appropriate when probability estimates are reliable
#'   \item Less intuitive than discrete outcome scoring
#' }
#'
#' @usage
#' utility.weighted(probt, probe, w1, w2, tox.upper)
#'
#' @param probt Numeric vector of estimated toxicity probabilities for each dose.
#'   Values should be between 0 and 1.
#' @param probe Numeric vector of estimated efficacy probabilities for each dose.
#'   Values should be between 0 and 1. Must have same length as \code{probt}.
#'   Can be binary probabilities or normalized equivalent scores.
#' @param w1 Numeric value specifying the weight for the toxicity-efficacy trade-off.
#'   Represents the rate at which toxicity is traded against efficacy. Higher values
#'   indicate greater toxicity aversion. Typically ranges from 0.2 to 1.0.
#' @param w2 Numeric value specifying the additional penalty weight for doses
#'   exceeding the toxicity threshold (\code{tox.upper}). Applied as extra penalty
#'   beyond the base w1 penalty. Typically ranges from 0.5 to 2.0.
#' @param tox.upper Numeric value specifying the upper bound of acceptable toxicity
#'   probability. Doses with toxicity exceeding this threshold receive additional
#'   penalty w2.
#'
#' @return
#' Numeric vector of utility values for each dose, with the same length as the
#' input probability vectors. Higher utility values indicate more desirable doses.
#' Utility values can be negative when toxicity costs outweigh efficacy benefits.
#'
#' @examples
#' toxicity_probs <- c(0.05, 0.15, 0.30, 0.45, 0.60)
#' efficacy_probs <- c(0.20, 0.40, 0.60, 0.70, 0.65)
#'
#' # Moderate toxicity aversion
#' w1 <- 0.5  # Base penalty
#' w2 <- 1.0  # Additional penalty for high toxicity
#' threshold <- 0.35  # 35% toxicity threshold
#'
#' utilities <- utility.weighted(
#'   probt = toxicity_probs,
#'   probe = efficacy_probs,
#'   w1 = w1, w2 = w2,
#'   tox.upper = threshold
#' )
#'
#' # Display results
#' dose_comparison <- data.frame(
#'   Dose = 1:5,
#'   Toxicity = toxicity_probs,
#'   Efficacy = efficacy_probs,
#'   Utility = round(utilities, 3),
#'   Exceeds_Threshold = toxicity_probs > threshold
#' )
#' print(dose_comparison)
#'
#' # Identify optimal dose
#' optimal_dose <- which.max(utilities)
#' cat("Optimal dose:", optimal_dose,
#'     "with utility:", round(max(utilities), 3), "\n")
#'
#' @note
#' \itemize{
#'   \item Utility values can be negative when toxicity costs exceed efficacy benefits
#'   \item The function creates a discontinuity at the toxicity threshold (tox.upper)
#'   \item The toxicity threshold (tox.upper) should align with design parameters (typically phi2)
#' }
#'
#' @references
#' \itemize{
#'   \item Thall, P. F., & Cook, J. D. (2004). Dose-finding based on efficacy-toxicity
#'         trade-offs. \emph{Biometrics}, 60(3), 684-693.
#'   \item Yin, G., Li, Y., & Ji, Y. (2006). Bayesian dose-finding in phase I/II
#'         clinical trials using toxicity and efficacy odds ratios.
#'         \emph{Biometrics}, 62(3), 777-784.
#' }
#'
#' @seealso
#' \code{\link{utility.truncated.linear}} for piecewise linear utility function,
#' \code{\link{utility.scoring}} for discrete outcome scoring approach,
#' \code{\link{obd.select}} for optimal biological dose selection using utilities.
#'
#' @export

utility.weighted <- function(probt,probe,w1,w2,tox.upper)
{
  return(probe-w1*probt-w2*probt*(probt>tox.upper))
}

