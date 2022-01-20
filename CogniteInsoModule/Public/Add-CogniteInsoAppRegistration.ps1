

Function Add-CogniteInsoAppRegistration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory)]
        $Customer,
        [Parameter(Mandatory)]
        $Cluster,
        [Parameter(Mandatory)]
        $AppName
    )

    Process {
        $ManifestFile = "cognite-inso-manifest.json"

        $ModuleRoot = Split-Path $PSScriptRoot
        .$ModuleRoot/ResourceAccess.ps1 

        # Clean up any manifest files
        if (Test-Path $ManifestFile) {
            Remove-Item $ManifestFile
        }

        # Get CDF Enterprise Application registered in Customer AD and build a resource access object
        $CDFResourceAccess = ResourceAccess -Permissions user_impersonation -DisplayName "Cognitedata API: ${Cluster}"
        
        # Generate MS Graph resource access object
        $GraphResourceAccess= ResourceAccess -Permissions openid, email, offline_access, profile -DisplayName "Microsoft Graph"

        # Combine resource access objects and output as Json to manifest.json
        @($GraphResourceAccess, $CDFResourceAccess) | ConvertTo-Json -Depth 5 | Out-File $ManifestFile

        # Set callback path used by oauth2 proxy
        $CallbackPath = "/oauth2/callback"

        # Create or update App Registration
        $AppRegistration = az ad app create `
                --display-name $AppName `
                --available-to-other-tenants false `
                --oauth2-allow-implicit-flow false `
                --reply-urls "http://localhost:4180$CallbackPath" `
                "https://$Customer-test.cogniteapp.com$CallbackPath" `
                "https://$Customer.cogniteapp.com$CallbackPath" `
                --required-resource-accesses `@$ManifestFile | ConvertFrom-Json

        # Create or update Client Secret
        $ClientCredentials = az ad app credential reset --id $AppRegistration.appId --credential-description cogniteapps --end-date "2099-01-01" | ConvertFrom-Json

        # Clean up
        Remove-Item $ManifestFile

        # Write out data to be shared with Cognite representative
        Write-Host "Generated new credentials, please forward to Cognite Representative, we suggest using https://yopass.se/" -ForegroundColor Green
        Write-Host "--client-id $($ClientCredentials.appId) --client-secret $($ClientCredentials.password) --tenant-id $($ClientCredentials.tenant)"


    }
    }
