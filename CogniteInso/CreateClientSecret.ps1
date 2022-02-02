
function Base64EncodeString { 
    param ( $String ) 
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String) 
    [Convert]::ToBase64String($Bytes) 
}
function CreateClientSecret {
    param (
        [String] $AppId,
        [String] $SecretDescription
    )
    
    process {
        $startDate = Get-Date
                    
        $Credentials  = Get-AzADApplication -ApplicationId $appId | New-AzADAppCredential -CustomKeyIdentifier (Base64EncodeString -String $SecretDescription) -StartDate $startDate -EndDate $startDate.AddYears(99) 

        return $Credentials.SecretText

    }
}