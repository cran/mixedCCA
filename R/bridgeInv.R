#'
#'
############################################################################################
# For multilinear interpolation approximation for bridge Inverse
############################################################################################

############################################################################################
# Cutoff criteria based on the combination of variable types
############################################################################################

cutoff_bb <- function(zratio1, zratio2){0.9 * 2 * pmin(zratio1, zratio2)*(1-pmax(zratio1, zratio2))}
cutoff_tt <- function(zratio1, zratio2){0.9 * (1 - pmax(zratio1, zratio2)^2)}
cutoff_tc <- function(zratio1, zratio2 = NULL){0.9 * (1 - zratio1^2)}
cutoff_ct <- function(zratio1 = NULL, zratio2){0.9 * (1 - zratio2^2)}
cutoff_bc <- function(zratio1, zratio2 = NULL){0.9 * 2 * zratio1 * (1 - zratio1)}
cutoff_cb <- function(zratio1 = NULL, zratio2){0.9 * 2 * zratio2 * (1 - zratio2) }

cutoff_tb <- function(zratio1, zratio2){0.9 * 2 * pmax(zratio2, 1 - zratio2) * (1 - pmax(zratio2, 1 - zratio2, zratio1))}
cutoff_bt <- function(zratio1, zratio2){0.9 * 2 * pmax(zratio1, 1 - zratio1) * (1 - pmax(zratio1, 1 - zratio1, zratio2))}


cutoff_select <- function(type1, type2){
  if (type1 == "binary" & type2 == "binary") {
    cutoff_select <- cutoff_bb
  } else if (type1 == "trunc" & type2 == "trunc") {
    cutoff_select <- cutoff_tt
  } else if (type1 == "trunc" & type2 == "continuous") {
    cutoff_select <- cutoff_tc
  } else if (type1 == "continuous" & type2 == "trunc") {
    cutoff_select <- cutoff_ct
  } else if (type1 == "binary" & type2 == "continuous") {
    cutoff_select <- cutoff_bc
  } else if (type1 == "continuous" & type2 == "binary") {
    cutoff_select <- cutoff_cb
  } else if (type1 == "trunc" & type2 == "binary") {
    cutoff_select <- cutoff_tb
  } else if (type1 == "binary" & type2 == "trunc") {
    cutoff_select <- cutoff_bt
  } else {
    stop("Unrecognized type of variables. Should be one of continuous, binary or trunc.")
  }
}



############################################################################################
# Select which bridge inverse function based on the combinatino of variable types
############################################################################################

bridgeInv_select <- function(type1, type2) {
  if (type1 == "binary" & type2 == "binary") { bridgeInv_select <- bridgeInv_bb
  } else if (type1 == "trunc" & type2 == "trunc") { bridgeInv_select <- bridgeInv_tt
  } else if (type1 == "trunc" & type2 == "continuous") { bridgeInv_select <- bridgeInv_tc
  } else if (type1 == "continuous" & type2 == "trunc") { bridgeInv_select <- bridgeInv_ct
  } else if (type1 == "binary" & type2 == "continuous") { bridgeInv_select <- bridgeInv_bc
  } else if (type1 == "continuous" & type2 == "binary") { bridgeInv_select <- bridgeInv_cb
  } else if (type1 == "trunc" & type2 == "binary") { bridgeInv_select <- bridgeInv_tb
  } else if (type1 == "binary" & type2 == "trunc") { bridgeInv_select <- bridgeInv_bt
  } else {
    stop("Unrecognized type of variables. Should be one of continuous, binary or trunc.")
  }
}


# wrapper functions
bridgeInv_tc <- function(tau, zratio1, zratio2){
  zratio2 = NA
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_tc(zratio1 = zratio1) , zratio1 = zratio1, zratio2 = zratio2, comb = "20")
  return(out)
}

bridgeInv_ct <- function(tau, zratio1, zratio2){
  zratio1 = NA
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_tc(zratio1 = zratio2), zratio1 = zratio2, zratio2 = zratio1, comb = "20")
  return(out)
}


# wrapper function
bridgeInv_tt <- function(tau, zratio1, zratio2){
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_tt(zratio1 = zratio1, zratio2 = zratio2), zratio1 = zratio1, zratio2 = zratio2, comb = "22")
  return(out)
}


# wrapper functions
bridgeInv_tb <- function(tau, zratio1, zratio2){
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_tb(zratio1 = zratio1, zratio2 = zratio2), zratio1 = zratio1, zratio2 = zratio2, comb = "21")
  return(out)
}

bridgeInv_bt <- function(tau, zratio1, zratio2){
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_tb(zratio1 = zratio2, zratio2 = zratio1), zratio1 = zratio2, zratio2 = zratio1, comb = "21")
  return(out)
}


# wrapper function
bridgeInv_bc <- function(tau, zratio1, zratio2){
  zratio2 = NA
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_bc(zratio1 = zratio1), zratio1 = zratio1, zratio2 = zratio2, comb = "10")
  return(out)
}

bridgeInv_cb <- function(tau, zratio1, zratio2){
  zratio1 = NA
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_bc(zratio1 = zratio2), zratio1 = zratio2, zratio2 = zratio1, comb = "10")
  return(out)
}

# wrapper function
bridgeInv_bb <- function(tau, zratio1, zratio2){
  out <- latentcor::r_ml_wrapper(K = 0.9 * tau / cutoff_bb(zratio1 = zratio1, zratio2 = zratio2), zratio1 = zratio1, zratio2 = zratio2, comb = "11")
  return(out)
}
