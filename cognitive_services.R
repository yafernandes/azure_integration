library(httr)
library(jsonlite)
library(data.table)
library(readr)

source("set_environment.R")

#######################
##
## Text Analytics
##
## https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0/
##
#######################

headers = add_headers(c(
  "Content-Type" = "application/json",
  "Ocp-Apim-Subscription-Key" = text_analytics$key
))

body <- list(documents = fread("files/language.txt", encoding = 'UTF-8' ,header = TRUE))

resp <- POST(paste0(text_analytics$endpoint, "/languages"), body = toJSON(body), headers)
results <- fromJSON(content(resp, as="text"))$documents
results$detectedLanguages

body <- list(documents = fread("files/reviews.txt", encoding = 'UTF-8' ,header = TRUE, nrows = 100))

resp <- POST(paste0(text_analytics$endpoint, "/sentiment"), body = toJSON(body), headers)
results <- fromJSON(content(resp, as="text"))$documents
results

resp <- POST(paste0(text_analytics$endpoint, "/keyPhrases"), body = toJSON(body), headers)
results <- fromJSON(content(resp, as="text"))$documents
results$keyPhrases

resp <- POST(paste0(text_analytics$endpoint, "/topics"), body = toJSON(body), query = list(numberOfLanguagesToDetect = 4), headers)
http_status(resp)
location <- resp$headers$`operation-location`

# Status 202 means the job was accepted.  
# This will return an operation-location as the header in the response, where the value is the URL to query for the resulting topics.
# The endpoint will return a response including {"status": "notstarted"} before processing, {"status": "running"}
# while processing and {"status": "succeeded"} with the output once completed.

repeat {
  resp <- GET(location, headers)
  results <- fromJSON(content(resp, as="text"))
  if (results$status == "Succeeded") break;
  Sys.sleep(30)
}

topics <- results$operationProcessingResult$topics
head(topics[order(topics$score, decreasing = TRUE),])

#######################
##
## Bing Spell Check
##
## https://dev.cognitive.microsoft.com/docs/services/56e73033cf5ff80c2008c679/operations/57855119bca1df1c647bc358
##
#######################

headers = add_headers(c(
  "Content-Type" = "application/x-www-form-urlencoded",
  "Ocp-Apim-Subscription-Key" = bing_spell_check$key
))

resp <- POST(bing_spell_check$endpoint,
             body = list(text = "What is toodays anwser fot the questin?"),
             encode = "form",
             query = list(mode = "proof"), headers)
results <- fromJSON(content(resp, as="text"))
results$flaggedTokens

resp <- POST(bing_spell_check$endpoint,
             body = list(text = "He was going down the read carpet to red a book."),
             encode = "form",
             query = list(mode = "proof"), headers)
results <- fromJSON(content(resp, as="text"))
results$flaggedTokens

#######################
##
## Computer Vision
##
## https://westus.dev.cognitive.microsoft.com/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fc
##
#######################

headers = add_headers(c(
  "Content-Type" = "application/octet-stream",
  "Ocp-Apim-Subscription-Key" = computer_vision$key
))

resp <- POST(paste0(computer_vision$endpoint, "/ocr"), body = upload_file("files/road_sign.jpg"), headers)
results <- fromJSON(content(resp, as="text"))
results$regions$lines

visualFeatures <- "Categories,Tags,Description,Faces,ImageType,Color,Adult"
resp <- POST(paste0(computer_vision$endpoint, "/analyze"), body = upload_file("files/img01.jpg"), query = list(visualFeatures = visualFeatures), headers)
results <- fromJSON(content(resp, as="text"))
results$tags
results$description$captions

resp <- POST(paste0(computer_vision$endpoint, "/describe"), body = upload_file("files/img01.jpg"), query = list(maxCandidates = 5), headers)
http_status(resp)
results <- fromJSON(content(resp, as="text"))
results$description$captions


#######################
##
## Face API
##
## https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236
##
#######################

headers = add_headers(c(
  "Content-Type" = "application/octet-stream",
  "Ocp-Apim-Subscription-Key" = face$key
))

resp <- POST(paste0(face$endpoint, "/detect"),
             body = upload_file("files/faces.jpg"),
             query = list(returnFaceId = "true", returnFaceLandmarks = "true", returnFaceAttributes = "age,gender,headPose,smile,facialHair,glasses,emotion"),
             headers)
results <- fromJSON(content(resp, as="text"))
results$faceAttributes$age
results$faceAttributes$gender
results$faceAttributes$smile
results$faceAttributes$glasses

