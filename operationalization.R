# o16n

library(AzureSMR)
library(mrsdeploy)

source("set_environment.R")

azureStartVM(sc, vmName = mrs$vm_name)

remoteLogin(deployr_endpoint = mrs$endpoint, username = mrs$user, password = mrs$password, diff = FALSE)

pause()

library(randomForest)

fit <- randomForest(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, iris)

putLocalObject("fit")

# Installs randomForest package on the remote system so it can be part of the Snapshot.
resume()
install.packages("randomForest")
pause()

myFunction <- function(df) {
  # Loading libraries on remote sessions requires lib.lob = getwd() so it can load from the Snapshot.
  library(randomForest, lib.loc = getwd())
  return(predict(fit, df))
}

snapshot_id <- createSnapshot("myFunction")
service_name <- "myWS"
service_version <- "v1.0.0"
myWS <- publishService(service_name,
                       code = myFunction,
                       inputs = list(input = "data.frame"),
                       output = list(result = "vector"),
                       v = service_version,
                       snapshot = snapshot_id
                      )

library(httr)
library(jsonlite)

login_url <- paste(mrs$endpoint, "/login")
myWS_url <- paste(mrs$endpoint, "/api/myWS/v1.0.0")

headers <- c(Accept = "application/json", "Content-Type" = "application/json")

resp <- POST(login_url, body = toJSON(unbox(data.frame(username = mrs$user, password = mrs$password))), add_headers(.headers = headers))
access_token <- content(resp)$access_token

headers['Authorization'] = paste0('Bearer ', access_token)

input <- data.frame(Sepal.Length = c(4.7, 6.8), Sepal.Width = c(3.2, 2.9), Petal.Length = c(1.5, 5.4), Petal.Width = c(0.2, 2.1));
body <- toJSON(list(input = input), dataframe = 'columns')
resp <- POST(myWS_url, body = body, add_headers(.headers = headers))
fromJSON(content(resp, as="text"))$outputParameters

# Clean up
deleteSnapshot(snapshot_id)
deleteService(service_name, service_version)

remoteLogout()
azureStopVM(sc, vmName = mrs$vm_name)
