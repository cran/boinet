
#' Discrete Scoring Utility Function for Toxicity-Efficacy Trade-offs
#'
#' @description
#' Calculates utility scores using a discrete scoring system based on the four
#' possible combinations of binary toxicity and efficacy outcomes. This approach
#' assigns specific utility values to each outcome combination, providing an
#' intuitive and clinically interpretable method for dose selection that directly
#' reflects clinical preferences for different risk-benefit scenarios.
#'
#' The scoring utility function is particularly valuable when clinical stakeholders
#' can easily specify their preferences for discrete outcome scenarios rather than
#' dealing with continuous probability trade-offs. It naturally handles the
#' clinical reality that the combination of toxicity and efficacy outcomes
#' may have non-additive effects on clinical utility.
#'
#' @details
#' \strong{Mathematical Formulation:}
#'
#' The utility function is based on expected utility across four discrete outcomes:
#'
#' \deqn{U(p_T, p_E) = \sum_{t \in \{0,1\}} \sum_{e \in \{0,1\}} P(T=t, E=e) \cdot \psi_{te}}
#'
#' Assuming independence between toxicity and efficacy:
#' \deqn{U(p_T, p_E) = \psi_{00}(1-p_T)(1-p_E) + \psi_{01}(1-p_T)p_E + \psi_{10}p_T(1-p_E) + \psi_{11}p_T p_E}
#'
#' Where:
#' \itemize{
#'   \item \eqn{\psi_{00}}: Utility score for (Toxicity=No, Efficacy=No)
#'   \item \eqn{\psi_{01}}: Utility score for (Toxicity=No, Efficacy=Yes)
#'   \item \eqn{\psi_{10}}: Utility score for (Toxicity=Yes, Efficacy=No)
#'   \item \eqn{\psi_{11}}: Utility score for (Toxicity=Yes, Efficacy=Yes)
#' }
#'
#' **Default Implementation:**
#' This function uses a simplified 2-parameter version with fixed values:
#' \itemize{
#'   \item \eqn{\psi_{01} = 100}: Best outcome (efficacy without toxicity)
#'   \item \eqn{\psi_{10} = 0}: Worst outcome (toxicity without efficacy)
#'   \item \eqn{\psi_{00}}: User-specified (typically 30-60)
#'   \item \eqn{\psi_{11}}: User-specified (typically 40-80)
#' }
#'
#' \strong{Comparison with Other Utility Functions:}
#'
#' **vs. Weighted Utility:**
#' \itemize{
#'   \item More intuitive for clinical stakeholders
#'   \item Better handling of outcome interactions
#'   \item Less flexible for continuous trade-offs
#'   \item More suitable for committee-based decisions
#' }
#'
#' **vs. Truncated Linear:**
#' \itemize{
#'   \item Simpler parameter specification
#'   \item More appropriate for binary thinking
#'   \item Less sophisticated modeling of probability ranges
#'   \item Better for stakeholder engagement
#' }
#'
#' @usage
#' utility.scoring(probt, probe, psi00, psi11)
#'
#' @param probt Numeric vector of estimated toxicity probabilities for each dose.
#'   Values should be between 0 and 1.
#' @param probe Numeric vector of estimated efficacy probabilities for each dose.
#'   Values should be between 0 and 1. Must have same length as \code{probt}.
#' @param psi00 Numeric value specifying the utility score for the outcome
#'   combination (Toxicity=No, Efficacy=No). Typically ranges from 30-70,
#'   representing the clinical value of avoiding harm while missing therapeutic benefit.
#' @param psi11 Numeric value specifying the utility score for the outcome
#'   combination (Toxicity=Yes, Efficacy=Yes). Typically ranges from 40-80,
#'   representing the net clinical value when efficacy is achieved despite toxicity.
#'
#' @return
#' Numeric vector of expected utility values for each dose, with the same length
#' as the input probability vectors. Values typically range from 0 to 100, where
#' higher values indicate more desirable risk-benefit profiles. The maximum
#' possible utility is 100 (efficacy without toxicity) and minimum is 0
#' (toxicity without efficacy).
#'
#' @examples
#' # Example 1: Basic scoring utility calculation
#' # Scenario: Acute leukemia treatment with curative intent
#'
#' # Dose-response probabilities
#' toxicity_probs <- c(0.10, 0.25, 0.40, 0.55, 0.70)
#' efficacy_probs <- c(0.20, 0.45, 0.65, 0.80, 0.85)
#'
#' # Curative intent scoring: ineffectiveness penalized, mixed outcome acceptable
#' psi_safe_ineffective <- 35  # Low score for missing cure opportunity
#' psi_toxic_effective <- 75   # High score for achieving cure despite toxicity
#'
#' utilities <- utility.scoring(
#'   probt = toxicity_probs, probe = efficacy_probs,
#'   psi00 = psi_safe_ineffective, psi11 = psi_toxic_effective
#' )
#'
#' # Display outcome probability breakdown
#' results <- data.frame(
#'   Dose = 1:5,
#'   P_Tox = toxicity_probs,
#'   P_Eff = efficacy_probs,
#'   P_Safe_Ineffective = round((1-toxicity_probs) * (1-efficacy_probs), 3),
#'   P_Safe_Effective = round((1-toxicity_probs) * efficacy_probs, 3),
#'   P_Toxic_Ineffective = round(toxicity_probs * (1-efficacy_probs), 3),
#'   P_Toxic_Effective = round(toxicity_probs * efficacy_probs, 3),
#'   Expected_Utility = round(utilities, 1)
#' )
#' print(results)
#'
#' # Optimal dose selection
#' optimal_dose <- which.max(utilities)
#' cat("\\nOptimal dose for curative intent:", optimal_dose,
#'     "with utility:", round(max(utilities), 1), "\\n")
#'
#' @note
#' \itemize{
#'   \item The function assumes independence between toxicity and efficacy outcomes
#'   \item Fixed utility scores: 100 for (safe, effective) and 0 for (toxic, ineffective)
#'   \item User-specified scores (psi00, psi11) should reflect clinical context and stakeholder values
#' }
#'
#' @references
#' \itemize{
#'   \item Thall, P. F., & Cook, J. D. (2004). Dose-finding based on efficacy-toxicity
#'         trade-offs. \emph{Biometrics}, 60(3), 684-693.
#'   \item Houede, N., Thall, P. F., Nguyen, H., Paoletti, X., & Kramar, A. (2010).
#'         Utility-based optimization of combination therapy using ordinal toxicity
#'         and efficacy in phase I/II trials. \emph{Biometrics}, 66(2), 532-540.
#' }
#'
#' @seealso
#' \code{\link{utility.weighted}} for continuous trade-off approach,
#' \code{\link{utility.truncated.linear}} for piecewise linear utility,
#' \code{\link{obd.select}} for optimal biological dose selection using utilities.
#'
#' @export

utility.scoring <- function(probt,probe,psi00,psi11)
{
  psi.e0t1 <- 0
  psi.e0t0 <- psi00
  psi.e1t1 <- psi11
  psi.e1t0 <- 100

  ut = (  psi.e0t1*(1-probe)*probt
        + psi.e0t0*(1-probe)*(1-probt)
        + psi.e1t1*probe    *probt
        + psi.e1t0*probe    *(1-probt))

  return(ut)
}

