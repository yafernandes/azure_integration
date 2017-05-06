library(httr)
library(jsonlite)

source("set_environment.R")

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

imageFile <- "files/faces.jpg"
resp <- POST(paste0(face$endpoint, "/detect"),
             body = upload_file(imageFile),
             query = list(returnFaceId = "true", returnFaceLandmarks = "true", returnFaceAttributes = "age,gender,headPose,smile,facialHair,glasses,emotion"),
             headers)
results <- fromJSON(content(resp, as="text"))

htmlFile <- "output_faces.html"
if(file.exists(htmlFile)) file.remove(htmlFile)
fileConn <- file(htmlFile, open = 'a')
writeLines(sprintf("<img src='%s' style='position:absolute;top:0;left:0'/>", imageFile), fileConn)

getText <- function(result) {
  return(sprintf("Gender: %s\nAge: %s\nSmile: %s\nGlasses: %s\nHeadpose (pitch/roll/yaw): %s/%s/%s\nFacial Hair (moustache/beard/sideburns): %s/%s/%s\nAnger: %s\nContempt: %s\nDisgust: %s\nHappiness: %s\nNeutral: %s\nSadness: %s\nSurprise: %s\nAnger: %s\n",
                 result$faceAttributes$gender,
                 result$faceAttributes$age,
                 result$faceAttributes$smile,
                 result$faceAttributes$glasses,
                 result$faceAttributes$headPose$pitch,
                 result$faceAttributes$headPose$roll,
                 result$faceAttributes$headPose$yaw,
                 result$faceAttributes$facialHair$moustache,
                 result$faceAttributes$facialHair$beard,
                 result$faceAttributes$facialHair$sideburns,
                 result$faceAttributes$emotion$anger,
                 result$faceAttributes$emotion$contempt,
                 result$faceAttributes$emotion$disgust,
                 result$faceAttributes$emotion$fear,
                 result$faceAttributes$emotion$happiness,
                 result$faceAttributes$emotion$neutral,
                 result$faceAttributes$emotion$sadness,
                 result$faceAttributes$emotion$surprise
  ))
}

for(i in 1:nrow(results)) {
  for(j in 1:nrow(results[i,])) {
    writeLines(sprintf("<div style='border:1px solid #FF0000;position:absolute;left:%s;top:%s;width:%spx;height:%spx;z-index:2' title='%s'></div>",
                       results[i,]$faceRectangle$left, results[i,]$faceRectangle$top,results[i,]$faceRectangle$width, results[i,]$faceRectangle$height,
                       getText(results[i,])),
               fileConn)
  }
}

flush(fileConn)
close(fileConn)

