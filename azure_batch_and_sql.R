library(RODBC)
library(doAzureParallel)

source("set_environment.R")

pool <- makeCluster("files/pool_config.json", wait = FALSE)
registerDoAzureParallel(pool)

con <- odbcDriverConnect(sql_server$odbc_connection_string)

groups <- sqlQuery(con, "SELECT Origin, COUNT(*) as nEvents FROM AirlineData GROUP BY Origin")
odbcCloseAll()
origins <- groups[groups$nEvents > 10000,c("Origin")]

error_handler <- function (e, origin) {
  azurePutBlob(sc, paste0("/debug/",origin ,".error.txt"), content = e$message)
  return(NULL)
}

getModel <- function(sc, sql_server, origin) {
  library(RODBC)
  library(caret)
  library(binda)
  library(AzureSMR)
  library(base64enc)
  
  attempts <- 0
  repeat {
    con <- odbcDriverConnect(sql_server$odbc_connection_string)
    attempts <- attempts + 1
    if (con != -1) break;
    if (attempts > 5) stop("Cannot connect to the database.")
    Sys.sleep(sample(1:3, 1))
  }

  df <- sqlQuery(con, paste0("SELECT Month, DayOfWeek, Dest, UniqueCarrier, ArrDelay FROM AirlineData WHERE Origin ='", origin, "'"), stringsAsFactors = TRUE)
  odbcCloseAll()

  df <- df[complete.cases(df),]
  df$delayed <- as.factor(df$ArrDelay > 15)
  df$ArrDelay <- NULL

  fitControl <- trainControl(
    method = "repeatedcv",
    number = 5,
    repeats = 5,
    allowParallel = FALSE)
  azurePutBlob(sc, paste0("/airport_models/",origin ,".model.rds"), content = "placeholder")
  set.seed(825)
  fit <- train(delayed ~ ., data = df, 
                   method = "binda", 
                   trControl = fitControl,
                   verbose = FALSE)

  tryCatch(
    azurePutBlob(sc, paste0("/airport_models/",origin ,".model.rds"), content = base64encode(memCompress(serialize(fit, NULL), type = "bzip2"))),
    error = function(e) {error_handler(e, origin)}
  )
  return(NULL)
}

system.time(models <- foreach(origin = origins) %dopar% {
  getModel(sc, sql_server, origin)
})

fit <- unserialize(memDecompress(base64decode(azureGetBlob(sc, "/airport_models/BOS.model.rds")), type = "unknown"))
fit

stopCluster(pool)
