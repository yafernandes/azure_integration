# R and Azure

Make sure your application has access to the resources you intend to use.  You grant access from within the resource, resource group, or subscription that is the scope of the role assignment.  

## Useful links
[Getting Started with Azure API](https://docs.microsoft.com/en-us/rest/api/)  
[Quickstart Guide for httr](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html)  
[Azure SMR](https://github.com/Microsoft/AzureSMR)  
[doAzureParallel](https://github.com/Azure/doAzureParallel)  

## Packages used
- [AzureSMR](https://github.com/Microsoft/AzureSMR)
- [doAzureParallel](https://github.com/Azure/doAzureParallel)
- httr
- jsonlite
- data.table
- readr
- mrsdeploy
- randomForest

## FAQ

* **How to create an application ID and secret?**  
  When you have an application that needs to access or modify resources, you must set up an Active Directory (AD) application and assign the required permissions to it. This approach is preferable to running the app under your own credentials.  [Use portal to create Active Directory application and service principal that can access resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

* **How to get my tenant ID?**  
  [Get tenant ID](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-tenant-id)

* **What role should I assign to my application?**  
  It depends on what you intend to do.  You can find more information about the difference roles [here](https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles).

* **I got error code 403.  What does it mean?**  
  It is likely related to [HTTP 403](https://en.wikipedia.org/wiki/HTTP_403).  You were trying to perform an operation which your application was not authorized.  To access resources in your subscription, you must assign the application to a role.
  
* **What kind of authentication is used with Azure Data Lake?**  
  We use Service-to-service authentication (non-interactive).   [Source](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-get-started-rest-api#how-do-i-authenticate-using-azure-active-directory)

