Function Initialize-CdfApiRegistration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory)]
        $CdfCluster
    )

    Process {
        # Load Utility Functions
        $ModuleRoot = Split-Path $PSScriptRoot
        $SeparatorCharacter = [IO.Path]::DirectorySeparatorChar
        .($ModuleRoot + $SeparatorCharacter + "Utilities.ps1")

        if (-Not (IsCdfCluster -CdfCluster $CdfCluster)){
            Write-Error "The cluster your provided: '$CdfCluster' is not a valid CDF Cluster"
            return
        }

        $context = Get-AzContext
        $tenantId = $context.Tenant.Id

        Start-Process "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=https://$CdfCluster.cognitedata.com"
    }
}