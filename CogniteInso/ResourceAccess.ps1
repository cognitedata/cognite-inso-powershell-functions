function ResourceAccess {
    Param (
        [String] $DisplayName,
        [String[]] $Permissions
    )

    Process {
        $ServicePrincipal = Get-AzADServicePrincipal -DisplayName $DisplayName


        $ResourceAccess = @{
            ResourceAppId = $ServicePrincipal.AppId
            ResourceAccess = @()
        }

        foreach ($Permission in $Permissions) {
            $Oauth2PermissionScope = $ServicePrincipal.Oauth2PermissionScope | Where-Object {$_.value -eq $Permission}

            if ($null -ne $Oauth2PermissionScope) {
                $ResourceAccess.ResourceAccess += @{
                    Id = $Oauth2PermissionScope.Id
                    Type = "Scope"
                }
            }else{
                Write-Host "Error finding permission scope for $Permission, skipping" -ForegroundColor Red
            }
        }
        
        return $ResourceAccess
    }
}