

function Add-Cognite-Inso-App-Registration {

    param (
        [Parameter(Mandatory)]
        $Customer,
        [Parameter(Mandatory)]
        $Cluster,
        [Parameter(Mandatory)]
        $AppName
    )

    $MANIFEST_FILE = "manifest.json"

    # Clean up any manifest files
    if (Test-Path $MANIFEST_FILE) {
        Remove-Item $MANIFEST_FILE
    }

    # Get CDF Enterprise Application registered in Customer AD and build a resource access object
    $CDF_SP = az ad sp list --display-name "Cognitedata API: ${Cluster}" | ConvertFrom-Json
    $SP_ID = $CDF_SP[0].appId
    foreach ($permission in $CDF_SP[0].oauth2Permissions) {
        if ($permission.value -eq "user_impersonation") {
            $USER_IMPERSONATION_ID = $permission.id
        }    
    }
    $CDF_RESOURCE_ACCESS = @{
        resourceAppId     = "$SP_ID"
        resourceAccess = @(@{
            id = "$USER_IMPERSONATION_ID"
            type = "Scope"
        })
    }

    # Generate MS Graph resource access object
    $GRAPH_RESOURCE_ACCESS = @{
        resourceAppId = "00000003-0000-0000-c000-000000000000"
        resourceAccess = @(
            @{
                id = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
                type = "Scope"
            },
            @{
                id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
                type = "Scope"
            },
            @{
                id = "37f7f235-527c-4136-accd-4a02d197296e"
                type = "Scope"
            },
            @{
                id = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
                type = "Scope"
            },
            @{
                id = "14dad69e-099b-42c9-810b-d002981feec1"
                type = "Scope"
            }
        )
    }

    # Combine resource access objects and output as Json to manifest.json
    @($GRAPH_RESOURCE_ACCESS, $CDF_RESOURCE_ACCESS) | ConvertTo-Json -Depth 5 | Out-File $MANIFEST_FILE

    # Set callback path used by oauth2 proxy
    $CALLBACK_PATH = "/oauth2/callback"

    # Create or update App Registration
    $NEW_APP_REGISTRATION = az ad app create `
            --display-name $AppName `
            --available-to-other-tenants false `
            --oauth2-allow-implicit-flow false `
            --reply-urls "http://localhost:4180$CALLBACK_PATH" `
            "https://$Customer-test.cogniteapp.com$CALLBACK_PATH" `
            "https://$Customer.cogniteapp.com$CALLBACK_PATH" `
            --required-resource-accesses `@$MANIFEST_FILE | ConvertFrom-Json

    # Create or update Client Secret
    $CLIENT_SECRET = az ad app credential reset --id $NEW_APP_REGISTRATION.appId --credential-description cogniteapps --end-date "2099-01-01" | ConvertFrom-Json

    # Clean up
    Remove-Item $MANIFEST_FILE

    # Write out data to be shared with Cognite representative
    Write-Host "Generated new credentials, please forward to Application Administrator"
    Write-Host "--client-id $($CLIENT_SECRET.appId) --client-secret $($CLIENT_SECRET.password) --tenant-id $($CLIENT_SECRET.tenant)"
}
