library(httr)
library(jsonlite)

source("set_environment.R")

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

imageFile <- "files/invoice.jpg"
resp <- POST(paste0(computer_vision$endpoint, "/ocr"), body = upload_file(imageFile), headers)
results <- fromJSON(content(resp, as="text", flatten = FALSE))

htmlFile <- "output_ocr.html"
if(file.exists(htmlFile)) file.remove(htmlFile)
fileConn <- file(htmlFile, open = 'a')
writeLines(sprintf("<img src='%s' style='position:absolute;top:0;left:0'/>", imageFile), fileConn)

for(i in 1:nrow(results$regions)) {
  p <- strtoi(strsplit(results$regions[i,]$boundingBox, split = ',')[[1]])
  margin <- 4
  writeLines(sprintf("<div style='border:2px solid #0000DD;position:absolute;left:%s;top:%s;width:%spx;height:%spx;z-index:0' title='%s'></div>",
                     p[1] - margin, p[2] - margin, p[3] + margin * 2, p[4] + margin * 2,
                     sprintf("Region %s", i)),
             fileConn)
  for(j in 1:length(results$regions[i,]$lines)) {
    for(k in 1:nrow(results$regions[i,]$lines[[j]])) {
      p <- strtoi(strsplit(results$regions[i,]$lines[[j]][k,]$boundingBox, split = ',')[[1]])
      margin <- 2
      writeLines(sprintf("<div style='border:2px solid #00DD00;position:absolute;left:%s;top:%s;width:%spx;height:%spx;z-index:0' title='%s'></div>",
                         p[1] - margin, p[2] - margin, p[3] + margin * 2, p[4] + margin * 2,
                         sprintf("Region %s, Line %s, Words %s", i, j, k)),
                 fileConn)
      for(l in 1:nrow(results$regions[i,]$lines[[j]][k,])) {
        for(m in 1:length(results$regions[i,]$lines[[j]][k,]$words)) {
          for(n in 1:nrow(results$regions[i,]$lines[[j]][k,]$words[[m]])) {
            item <- results$regions[i,]$lines[[j]][k,]$words[[m]][n,]
            p <- strtoi(strsplit(item$boundingBox, split = ',')[[1]])
            margin <- 0
            writeLines(sprintf("<div style='border:1px solid #FF0000;position:absolute;left:%s;top:%s;width:%spx;height:%spx;z-index:2' title='%s'></div>",
                               p[1] - margin, p[2] - margin, p[3] + margin * 2, p[4] + margin * 2,
                               item$text),
                       fileConn)
          }
        }
      }
    }
  }
}

flush(fileConn)
close(fileConn)