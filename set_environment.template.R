####################
#
# Resources
#
# https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal
#
########################################

library(AzureSMR)

tenant <- list(id = '<REDACTED>')

app <- list(id = '<REDACTED>', secret = '<REDACTED>')

adls <- list(url = 'https://<REDACTED>.azuredatalakestore.net')

mrs <- list(
  vm_name = '<REDACTED>',
  hostname = "<REDACTED>.cloudapp.azure.com",
  user = "<REDACTED>",
  password = "<REDACTED>",
  port = 12800
)

mrs[["endpoint"]] = paste0("http://", mrs$hostname, ":", mrs$port)

sc <- createAzureContext(tenantID = tenant$id, clientID = app$id, authKey = app$secret)

setAzureContext(sc, resourceGroup = "<REDACTED>")
setAzureContext(sc, subscriptionID = "<REDACTED>")
.storageKey <- azureSAGetKey(sc, "<REDACTED>")
if (is.null(.storageKey)) {
  warning("We were not able to retrieve a key for your storage account.  Please check if the application has the rights permissions setup.")
} else {
  setAzureContext(sc, storageAccount = "<REDACTED>", storageKey = .storageKey)
}
rm(.storageKey)
setAzureContext(sc, storageAccount = "<REDACTED>", storageKey = storageKey)
setAzureContext(sc, container = "<REDACTED>")

#########################
# Cognitive Services
#########################

text_analytics = list(
  endpoint = "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0",
  key = "<REDACTED>"
)

bing_spell_check = list(
  endpoint = "https://api.cognitive.microsoft.com/bing/v5.0/spellcheck",
  key = "<REDACTED>"
)

computer_vision = list(
  endpoint = "https://westus.api.cognitive.microsoft.com/vision/v1.0",
  key = "<REDACTED>"
)

face = list(
  endpoint = "https://westus.api.cognitive.microsoft.com/face/v1.0",
  key = "<REDACTED>"
)