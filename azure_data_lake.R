####################
#
# Resources
#
# https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-authenticate-using-active-directory
# https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-get-started-rest-api
#
####################

library(httr)
library(readr)

source("set_environment.R")

base_url <- paste0("https://login.microsoftonline.com/", tenant$id, "/oauth2")

# Get access token
resp <- POST(paste0(base_url, "/token"), body = list(grant_type = "client_credentials", client_id = app$id, client_secret = app$secret, resource = "https://management.core.windows.net/"))
access_token = content(resp)$access_token

# Header with authentication information
header <- add_headers(Authorization = paste0("Bearer ", access_token))
  
base_adls_url <- paste0(adls$url, "/webhdfs/v1")

file_path <- tempfile(pattern = "adls_", tmpdir = '/tmp', fileext = '.txt')

# If we are running on Windows, we need to fix the backward slashed.
file_path <- gsub("\\\\", "/", file_path)

# Writes cars to ADLS then retrieves it.
resp <- PUT(paste0(base_adls_url, file_path),
            query = list(op = "CREATE", write = "true", overwrite = "true"),
            body = format_csv(cars),
            header)

resp <- GET(paste0(base_adls_url, file_path), query = list(op = "OPEN"), header)

df <- content(resp, "parsed", type = "text/csv" )

df

# Deletes the resource from ADLS
resp <- DELETE(paste0(base_adls_url, file_path), query = list(op = "DELETE"), header)

