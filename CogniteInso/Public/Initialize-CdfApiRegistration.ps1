Function Initialize-CdfApiRegistration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory)]
        $CdfCluster
    )

    Process {
        $context = Get-AzContext
        $tenantId = $context.Tenant.Id

        Start-Process "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=https://$CdfCluster.cognitedata.com"
    }
}