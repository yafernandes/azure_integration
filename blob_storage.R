####################
#
# Resources
#
# https://github.com/Microsoft/AzureSMR
#
####################

library(AzureSMR)
library(data.table)
library(readr)


# Creates my Azure context, inclusing access keys and storage account.
source("set_environment.R")

file_path <- tempfile(pattern = "blob_", tmpdir = '/tmp', fileext = '.txt')

# List containers available
azureListStorageContainers(sc)

# List blobs
azureListStorageBlobs(sc)

# Writes cars to blob storage
azurePutBlob(sc, file_path, content = format_csv(cars))

# Reads cars from blob storage
df <- fread(azureGetBlob(sc, file_path))

# List blobs
azureListStorageBlobs(sc)

# Delete blob
azureDeleteBlob(sc, file_path)

# List blobs
azureListStorageBlobs(sc)




