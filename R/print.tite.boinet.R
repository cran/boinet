
#' Print tite.boinet
#'
#' Display key summary results from \code{tite.boinet}.
#' @param x Object from \code{tite.boinet}.
#' @param ... More options to pass to print.
#' @rdname print.tite.boinet
#' @return
#' No return values. Key summary results from \code{tite.boinet} are displayed with
#' trial design settings.
#' @seealso \code{\link{tite.boinet}}
#' @export

print.tite.boinet <- function(x,...)
{
  ptab1 <- rbind(
    x$toxprob,
    x$effprob,
    x$n.patient,
    x$prop.select)
  rnames <- c("Toxicity prob.","Efficacy prob.","No. Pts treated","Select %")
  dimnames(ptab1) <- list(rnames,names(x$toxprob))

  ptab2 <- rbind(
    x$prop.stop,
    x$duration)
  rnames <- c(names(x$prop.stop),names(x$duration))
  dimnames(ptab2) <- list(rnames,"")

  ptab3 <- rbind(
    x$phi,
    x$delta,
    x$lambda1,
    x$lambda2,
    x$eta1)
  rnames <- c(names(x$phi),names(x$delta),names(x$lambda1),names(x$lambda2),names(x$eta1))
  dimnames(ptab3) <- list(rnames,"")

  ptab4 <- rbind(
    x$tau.T,
    x$tau.E,
    x$accrual)
  rnames <- c(names(x$tau.T),names(x$tau.E),names(x$accrual))
  dimnames(ptab4) <- list(rnames,"")

  cat("\n")
  cat("Simulation results:\n")
  cat("\n")
  print.default(ptab1,print.gap=2L,quote=FALSE)
  print.default(ptab2,print.gap=2L,quote=FALSE)
  cat("\n")
  cat("Trial design settings:\n")
  print.default(ptab3,print.gap=2L,quote=FALSE)
  print.default(ptab4,print.gap=2L,quote=FALSE)
  cat("\n")
  cat("Efficacy prob. estimation:",x$estpt.method)
  cat("\n")
  cat("\n")
  cat("OBD selection:",x$obd.method)
  cat("\n")
}
