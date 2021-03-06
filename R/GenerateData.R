#' Construct a correlation matrix
#'
#' Functions to create autocorrelation matrix (p by p) with parameter rho and block correlation matrix (p by p) using group index (of length p) and (possibly) different parameter rho for each group.
#' @name CorrStructure
NULL
#> NULL


#' @rdname CorrStructure
#' @param p Specified matrix dimension.
#' @param rho Correlation value(s), must be between -0.99 and 0.99. Should be a scalar for \code{autocor}, and either a scalar or a vector of the same length as the maximal \code{blockind} K for \code{blockcor}.
#' @export
autocor <- function(p, rho){
  if (abs(rho) > 0.99){ stop("correlation rho must be between -0.99 and 0.99.") }
  Sigma <- rho^abs(outer(1:p, 1:p, "-"))
  return(Sigma)
}


#' Construct a correlation matrix
#' @rdname CorrStructure
#' @param blockind Block index 1,\dots, K for a positive integer K specifying which variable belongs to which block, the matrix dimension is equal to \code{length(blockind)}.
#' @param rho Correlation value(s), must be between -0.99 and 0.99. Should be a scalar for \code{autocor}, and either a scalar or a vector of the same length as the maximal \code{blockind} K for \code{blockcor}.
#' @examples
#' # For p = 8,
#' # auto correlation matrix
#' autocor(8, 0.8)
#' # block correlation matrix: two blocks with the same correlation within each block
#' blockcor(c(rep(1,3), rep(2,5)), 0.8)
#' # block correlation matrix: two blocks with different correlation within each block
#' blockcor(c(rep(1,3), rep(2,5)), c(0.8, 0.3))
#'
#' @export
blockcor <- function(blockind, rho){
  if(max(abs(rho)) > 0.99){ stop("correlation rho must be between -0.99 and 0.99.") }

  p <- length(blockind)
  blk <- unique(blockind)
  if (length(rho) != length(blk)){
    if(length(rho) == 1){
      rho <- rep(rho, length(blk))
    } else {
      stop("rho and number of groups must match.")
    }
  }
  Sigma <- matrix(0, p, p)

  for (j in 1:length(blk)){
    coef <- which(blockind %in% blk[j])
    Sigma[coef, coef] <- rho[j]
  }
  diag(Sigma) = 1
  return(Sigma)
}

#' Mixed type simulation data generator for sparse CCA
#'
#' \code{GenerateData} is used to generate two sets of data of mixed types for sparse CCA under the Gaussian copula model.
#'
#' @param n Sample size
#' @param trueidx1 True canonical direction of length p1 for \code{X1}. It will be automatically normalized such that \eqn{w_1^T \Sigma_1 w_1 = 1}.
#' @param trueidx2 True canonical direction of length p2 for \code{X2}. It will be automatically normalized such that \eqn{w_2^T \Sigma_2 w_2 = 1}.
#' @param Sigma1 True correlation matrix of latent variable \code{Z1} (p1 by p1).
#' @param Sigma2 True correlation matrix of latent variable \code{Z2} (p2 by p2).
#' @param maxcancor True canonical correlation between \code{Z1} and \code{Z2}.
#' @param copula1 Copula type for the first dataset. U1 = f(Z1), which could be either "exp", "cube".
#' @param copula2 Copula type for the second dataset. U2 = f(Z2), which could be either "exp", "cube".
#' @param type1 Type of the first dataset \code{X1}. Could be "continuous", "trunc" or "binary".
#' @param type2 Type of the second dataset \code{X2}. Could be "continuous", "trunc" or "binary".
#' @param muZ Mean of latent multivariate normal.
#' @param c1 Constant threshold for \code{X1} needed for "trunc" and "binary" data type - the default is NULL.
#' @param c2 Constant threshold for \code{X2} needed for "trunc" and "binary" data type - the default is NULL.
#'
#' @return \code{GenerateData} returns a list containing
#' \itemize{
#'       \item{Z1: }{latent numeric data matrix (n by p1).}
#'       \item{Z2: }{latent numeric data matrix (n by p2).}
#'       \item{X1: }{observed numeric data matrix (n by p1).}
#'       \item{X2: }{observed numeric data matrix (n by p2).}
#'       \item{true_w1: }{normalized true canonical direction of length p1 for \code{X1}.}
#'       \item{true_w2: }{normalized true canonical direction of length p2 for \code{X2}.}
#'       \item{type: }{a vector containing types of two datasets.}
#'       \item{maxcancor: }{true canonical correlation between \code{Z1} and \code{Z2}.}
#'       \item{c1: }{constant threshold for \code{X1} for "trunc" and "binary" data type.}
#'       \item{c2: }{constant threshold for \code{X2} for "trunc" and "binary" data type.}
#'       \item{Sigma: }{true latent correlation matrix of \code{Z1} and \code{Z2} ((p1+p2) by (p1+p2)).}
#' }
#' @export
#'
#' @importFrom MASS mvrnorm
#' @example man/examples/GenerateData_ex.R
#'
GenerateData <- function(n, trueidx1, trueidx2, Sigma1, Sigma2, maxcancor,
                         copula1 = "no", copula2 = "no",
                         type1 = "continuous", type2 = "continuous", muZ = NULL, c1 = NULL, c2 = NULL
){

  if((type1 != "continuous") & is.null(c1)){
    stop("c1 has to be defined for truncated continuous and binary data type.")
  }
  if((type2 != "continuous") & is.null(c2)){
    stop("c2 has to be defined for truncated continuous and binary data type.")
  }

  p1 <- length(trueidx1)
  p2 <- length(trueidx2)
  p <- p1 + p2

  # normalize to satisfy t(theta1)%*%Sigma1%*%theta1=1
  th1 <- trueidx1/sqrt(as.numeric(crossprod(trueidx1, Sigma1 %*% trueidx1)))
  th2 <- trueidx2/sqrt(as.numeric(crossprod(trueidx2, Sigma2 %*% trueidx2)))
  Sigma12 <- maxcancor*Sigma1%*%th1%*%t(th2)%*%Sigma2
  JSigma <- rbind(cbind(Sigma1, Sigma12), cbind(t(Sigma12), Sigma2))

  # jointly generate X and Y using two canonical pairs
  if (is.null(muZ)) {
    muZ <- rep(0, p)
  }
  dat <- MASS::mvrnorm(n, mu = muZ, Sigma = JSigma) # generate a data matrix of size: n by length(muZ). length(muZ) should match with ncol(JSigma)=nrow(JSigma).

  Z1 <- dat[, 1:p1]
  Z2 <- dat[, (p1+1):p]

  # Three different types of copula
  if(copula1 != "no"){
    if(copula1 == "exp"){
      Z1 <- exp(Z1)
    }else if(copula1 == "cube"){
      Z1 <- Z1^3
    }
  }
  if(copula2 != "no"){
    if(copula2 == "exp"){
      Z2 <- exp(Z2)
    }else if(copula2 == "cube"){
      Z2 <- Z2^3
    }
  }

  if(type1 != "continuous"){
    if(length(c1) != p1) { stop("The length of threshold vector c1 does not match with the size of the data X1.") }
    if(length(c1) == 1) { warning("Same threshold is applied to the all variables in the first set.") }
  }
  if(type2 != "continuous"){
    if(length(c2) != p2) { stop("The length of threshold vector c2 does not match with the size of the data X2.") }
    if(length(c2) == 1) { warning("Same threshold is applied to the all variables in the second set.") }
  }

  if(type1 == "continuous") {
    X1 <- Z1
  } else if(type1 == "trunc") {
    X1 <- ifelse(Z1 > c1, Z1, 0)
  } else if (type1 == "binary") {
    X1 <- ifelse(Z1 > c1, 1, 0)
  }

  if(type2 == "continuous") {
    X2 <- Z2
  } else if(type2 == "trunc") {
    X2 <- ifelse(Z2 > c2, Z2, 0)
  } else if (type2 == "binary") {
    X2 <- ifelse(Z2 > c2, 1, 0)
  }

  return(list(Z1 = Z1, Z2 = Z2, X1 = X1, X2 = X2, true_w1 = th1, true_w2 = th2, type = c(type1, type2), maxcancor = maxcancor, c1 = c1, c2 = c2, Sigma = JSigma))
}


