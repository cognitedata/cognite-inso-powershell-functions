

Function Add-CogniteInsoGrafanaAppRegistration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory)]
        $CustomerName,
        [Parameter(Mandatory)]
        $CdfCluster,
        [Parameter(Mandatory)]
        $DisplayName
    )

    Process {
        # Load Utility Functions
        $ModuleRoot = Split-Path $PSScriptRoot
        $SeparatorCharacter = [IO.Path]::DirectorySeparatorChar
        .($ModuleRoot + $SeparatorCharacter + "ResourceAccess.ps1")
        .($ModuleRoot + $SeparatorCharacter + "GrantAdminConsent.ps1")
        .($ModuleRoot + $SeparatorCharacter + "CreateClientSecret.ps1")
        .($ModuleRoot + $SeparatorCharacter + "Utilities.ps1")

        if (-Not (IsCdfCluster -CdfCluster $CdfCluster)){
            Write-Error "The cluster your provided: '$CdfCluster' is not a valid CDF Cluster"
            return
        }

        $RequiredResourceAccess = @()
        # Get CDF Enterprise Application registered in Customer AD and build a resource access object
        $RequiredResourceAccess += ResourceAccess -Permissions user_impersonation -DisplayName "Cognitedata API: ${CdfCluster}"
        # Generate MS Graph resource access object
        $RequiredResourceAccess += ResourceAccess -Permissions openid, email, offline_access, profile -DisplayName "Microsoft Graph"

        # Generate ReplyUrls
        $ReplyUrls = $(           
            "https://grafana-$CustomerName.cogniteapp.com/login/azuread"
        )

        $AppRoles = @(
            @{
                AllowedMemberType = @("User")
                Description = "Grafana admin Users"
                DisplayName = "Grafana Admin"
                Id = [guid]::NewGuid()
                IsEnabled = $TRUE
                Value = "Admin"
            },
            @{
                AllowedMemberType = @("User")
                Description = "Grafana read only Users"
                DisplayName = "Grafana Viewer"
                Id = [guid]::NewGuid()
                IsEnabled = $TRUE
                Value = "Viewer"
            },
            @{
                AllowedMemberType = @("User")
                Description = "Grafana Editor Users"
                DisplayName = "Grafana Editor"
                Id = [guid]::NewGuid()
                IsEnabled = $TRUE
                Value = "Editor"
            }

        )

        # Check If App Registraion already exists
        $AppReg = Get-AzADApplication -DisplayName $DisplayName

        if ($null -eq $AppReg) {
            Write-Host "Application Registraion $DisplayName doesn't exist, creating..." -ForegroundColor Yellow
            $AppReg = New-AzADApplication -DisplayName $DisplayName -AvailableToOtherTenants $FALSE
            Write-Host "Created" -ForegroundColor Green
        }
        
        Write-Host "Updating Reply Url's..." -ForegroundColor Yellow
        Update-AzADApplication -ObjectId $AppReg.Id -ReplyUrls $ReplyUrls 
        Write-Host "Updated" -ForegroundColor Green

        Write-Host "Updating API Permissions..." -ForegroundColor Yellow
        Update-AzADApplication -ObjectId $AppReg.Id -RequiredResourceAccess $RequiredResourceAccess
        Write-Host "Updated" -ForegroundColor Green

        Write-Host "Updating App Roles..." -ForegroundColor Yellow
        Update-AzADApplication -ObjectId $AppReg.Id -AppRole $AppRoles
        Write-Host "Updated" -ForegroundColor Green

        Write-Host "Waiting for AD to reach consistency" -ForegroundColor Yellow
        Start-Sleep -Seconds 30

        Write-Host "Granting Admin Consent on API Permissions..." -ForegroundColor Yellow
        GrantAdminConsent -AppId $AppReg.AppId
        Write-Host "Granted" -ForegroundColor Green

        $SecretDescription = (Get-Date -Format "yyyy-MM-dd") + "-cognite-inso-apps"
        Write-Host "Generating Credentials..." -ForegroundColor Yellow
        $ClientSecret = CreateClientSecret -AppId $AppReg.AppId -SecretDescription $SecretDescription
        Write-Host "Created" -ForegroundColor Green

        $context = Get-AzContext

        Write-Host "Please send the following to your Cognite Representative securly, we reccommend https://yopass.se" -ForegroundColor Yellow
        Write-Host "App Name: $DisplayName --client-id $($AppReg.AppId) --client-secret $ClientSecret --tenant-id $($context.Tenant.Id)" -ForegroundColor Green
    }
}
