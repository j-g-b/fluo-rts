#
require(readr)
require(nnls)

#
source_eem_data <- readr::read_csv("source_eems.csv", name_repair = "minimal")
unknown_eem_data <- readr::read_csv("unknown_eems.csv")
source_labels <- colnames(source_eem_data)

#
sources <- unique(source_labels)
K <- length(sources)
N <- length(source_labels)
G <- matrix(0, nrow = K, ncol = N)
for(k in 1:K){
  for(n in 1:N){
    if(source_labels[n] == sources[k]){
      G[k, n] <- 1
    }
  }
}

#
source_contributions <- matrix(0, nrow = ncol(unknown_eem_data), ncol = K)
for(j in 1:ncol(unknown_eem_data)){
  #
  y <- unknown_eem_data[, j]
  X <- as.matrix(source_eem_data)
    
  #
  incl_rows <- apply(X, 1, function(x){!any(is.na(x))}) & !is.na(y)
  X <- X[incl_rows, ]
  y <- y[incl_rows]
  
  #
  coefs <- nnls::nnls(X, y)$x
  
  #
  source_contributions[j, ] <- G%*%coefs
}

#
source_contributions <- as.data.frame(source_contributions)
colnames(source_contributions) <- sources
source_contributions <- cbind(eem_name = colnames(unknown_eem_data), source_contributions)
readr::write_csv(source_contributions, "source_contributions.csv")
