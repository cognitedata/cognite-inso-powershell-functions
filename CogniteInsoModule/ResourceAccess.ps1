function ResourceAccess {
    Param (
        [String] $DisplayName,
        [String[]] $Permissions
    )

    Process {
        $graphSP = az ad sp list --display-name $DisplayName | ConvertFrom-Json
        if ($graphSP.appId -is [array]) {
            $appId = $graphSP.appId[0] # Deal with MS Graph multiple ID
        }else {
            $appId = $graphSP.appId
        }
        $ResourceAccess = @{
            resourceAppId = $appId
            resourceAccess = @()
        }
        foreach ($item in $graphSP.oauth2Permissions) {
            if ($Permissions -contains $item.value) {
                $ResourceAccess.ResourceAccess += @{
                        id = $item.id
                        type = "Scope"
                    }
            }
        }
        return $ResourceAccess
    }
}