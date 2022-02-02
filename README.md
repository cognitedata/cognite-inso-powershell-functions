# cognite-inso-powershell-functions
Useful Powershell Functions for working with the Cognite Industry Solutions team

## Installation

In PowerShell run:
```powershell
Install-Module CogniteInso
```

## Authenticating CLI

Run the following to authenticate with the Azure AD Tenant you wish to use:
```powershell
Connect-AzAccount -Tenant <YOUR TENANT ID>
```

## CommandLets

### Add-CogniteInsoAppRegistration

* Used to create an Application Registration for Cognite Industry Solutions web apps authentication.
* Adds the required Redirect URLs for the Oauth Proxy used to authenticate users
* Includes MS Graph permissions to keep the user logged in and provide the application with basic info about the user
* Includes API permission to the specified Cognite API
* Grants API permissions for all users on behalf of the admin
* Generates credentials valid for the next 99 years

__Parameters__
* `-CustomerName` - lower case, no spaces
* `-CdfCluster` - Used to provide permissions against the right CDF Cluster, eg use `api` for `https://api.cognitedata.com`
* `-DisplayName` - The name of the App Registration registered in the Azure AD

__Usage Example__
```powershell
Add-CogniteInsoAppRegistration -CustomerName acme -CdfCluster api -DisplayName cognite-inso-test                    
```

### Add-CogniteInsoGrafanaAppRegistration

* Used to create an Application Registration for Cognite Industry Solutions hosted Grafana authentication.
* Adds the required Redirect URL for the hosted Grafana instance
* Adds the required Application Roles - `Grafana Admin, Grafana Editor, Grafana Viewer`
* Includes MS Graph permissions to keep the user logged in and provide the application with basic info about the user
* Includes API permission to the specified Cognite API
* Grants API permissions for all users on behalf of the admin
* Generates credentials valid for the next 99 years

__Parameters__
* `-CustomerName` - lower case, no spaces
* `-CdfCluster` - Used to provide permissions against the right CDF Cluster, eg use `api` for `https://api.cognitedata.com`
* `-DisplayName` - The name of the App Registration registered in the Azure AD

__Usage Example__
```powershell
Add-CogniteInsoGrafanaAppRegistration -CustomerName acme -CdfCluster api -DisplayName cognite-inso-test                    
```

### Initialize-CdfApiRegistration

* Used to register a CDF Cluster API as an Enterprise Application on the Current users Azure AD Tenant

__Parameters__
* `-CdfCluster` - The CDF Cluster API you want to register as an Enterprise Application, eg use `api` for `https://api.cognitedata.com`

__Usage Example__
```powershell
Initialize-CdfApiRegistration -CdfCluster api                    
```