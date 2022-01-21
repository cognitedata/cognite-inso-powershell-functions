function GrantAdminConsent {
    param (
        [String] $AppId
    )
    
    process {
        $context = Get-AzContext
        $token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id, $null, "Never", $null, "74658136-14ec-4630-ad9b-26e160ff0fc6")
        $headers = @{
            'Authorization' = 'Bearer ' + $token.AccessToken
            'X-Requested-With'= 'XMLHttpRequest'
            'x-ms-client-request-id'= [guid]::NewGuid()
            'x-ms-correlation-id' = [guid]::NewGuid()}
        $url = "https://main.iam.ad.ext.azure.com/api/RegisteredApplications/$AppId/Consent?onBehalfOfAll=true"
        Invoke-RestMethod -Uri $url -Headers $headers -Method POST -ErrorAction Stop
    }
}