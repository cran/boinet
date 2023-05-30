
#' Print tite.gboinet
#'
#' Display key summary results from \code{tite.gboinet}.
#' @param x Object from \code{tite.gboinet}.
#' @param ... More options to pass to print.
#' @rdname print.tite.gboinet
#' @return
#' No return values. Key summary results from \code{tite.gboinet} are displayed with
#' trial design settings.
#' @seealso \code{\link{tite.gboinet}}
#' @export

print.tite.gboinet <- function(x,...)
{
  ptab1 <- rbind(
    x$toxprob,
    x$nETS,
    x$effprob,
    x$nEES,
    x$n.patient,
    x$prop.select)
  rnames <- c(paste("Tox.cat",1:(x$ncat.T[[1]]),sep=""),"nETS",
              paste("Eff.cat",1:(x$ncat.E[[1]]),sep=""),"nEES","No. Pts treated","Select %")
  dimnames(ptab1) <- list(rnames,colnames(x$toxprob))

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
