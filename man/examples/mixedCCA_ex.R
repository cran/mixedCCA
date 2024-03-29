### Simple example

# Data setting
n <- 100; p1 <- 15; p2 <- 10 # sample size and dimensions for two datasets.
maxcancor <- 0.9 # true canonical correlation

# Correlation structure within each data set
set.seed(0)
perm1 <- sample(1:p1, size = p1);
Sigma1 <- autocor(p1, 0.7)[perm1, perm1]
blockind <- sample(1:3, size = p2, replace = TRUE);
Sigma2 <- blockcor(blockind, 0.7)
mu <- rbinom(p1+p2, 1, 0.5)

# true variable indices for each dataset
trueidx1 <- c(rep(1, 3), rep(0, p1-3))
trueidx2 <- c(rep(1, 2), rep(0, p2-2))

# Data generation
simdata <- GenerateData(n=n, trueidx1 = trueidx1, trueidx2 = trueidx2, maxcancor = maxcancor,
                        Sigma1 = Sigma1, Sigma2 = Sigma2,
                        copula1 = "exp", copula2 = "cube",
                        muZ = mu,
                        type1 = "trunc", type2 = "trunc",
                        c1 = rep(1, p1), c2 =  rep(0, p2)
)
X1 <- simdata$X1
X2 <- simdata$X2

# Check the range of truncation levels of variables
range(colMeans(X1 == 0))
range(colMeans(X2 == 0))

# Kendall CCA with BIC1
kendallcca1 <- mixedCCA(X1, X2, type1 = "trunc", type2 = "trunc", BICtype = 1, nlamseq = 10)

# Kendall CCA with BIC2. Estimated correlation matrix is plugged in from the above result.
R <- kendallcca1$KendallR
kendallcca2 <- mixedCCA(X1, X2, type1 = "trunc", type2 = "trunc",
                        KendallR = R, BICtype = 2, nlamseq = 10)
