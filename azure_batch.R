####################
#
# Resources
#
# https://azure.microsoft.com/en-us/blog/doazureparallel/
# https://github.com/Azure/doAzureParallel
#
####################

library(doAzureParallel)

# 1. Generate a pool configuration file.  
generateClusterConfig("files/pool_config.json")

# 2. Edit your pool configuration file.
# Enter your Azure Batch Account & Azure Storage keys/account-info and configure your pool settings.

# 3. Register the pool. This will create a new pool if your pool hasn't already been provisioned.
pool <- makeCluster("files/pool_config.json")

# 4. Register the pool as your parallel backend
registerDoAzureParallel(pool)

# 5. Check that your parallel backend has been registered
getDoParWorkers()

mean_change = 1.001
volatility = 0.01
opening_price = 100

simulateMovement <- function() {
  days <- 1825 # ~ 5 years
  movement <- rnorm(days, mean=mean_change, sd=volatility)
  path <- cumprod(c(opening_price, movement))
  return(path)
}


getClosingPrice <- function() {
  days <- 1825 # ~ 5 years
  movement <- rnorm(days, mean=mean_change, sd=volatility)
  path <- cumprod(c(opening_price, movement))
  closingPrice <- path[days]
  return(closingPrice)
}

system.time(
  closingPrices <- foreach(i = 1:10, .combine='c') %do% {
    replicate(100000, getClosingPrice())
  }
)

system.time(
  closingPrices <- foreach(i = 1:50, .combine='c') %dopar% {
    replicate(100000, getClosingPrice())
  }
)

hist(closingPrices)

# shut down your pool
stopCluster(pool)
