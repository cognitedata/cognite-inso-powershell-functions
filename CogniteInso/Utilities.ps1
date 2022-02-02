function IsCdfCluster {
    param(
        $CdfCluster
    )
    process {
        $Clusters = @(
            "api",
            "asia-northeast1-1",
            "az-ams-aloe",
            "az-eastus-1",
            "az-energinet-westeurope",
            "az-power-no-northeurope",
            "azure-dev",
            "bluefield",
            "bp-northeurope",
            "greenfield",
            "okd-dev-01",
            "omv",
            "openfield",
            "pgs",
            "power-no",
            "sandfield",
            "statnett",
            "westeurope-1"
        )

        return $Clusters.Contains($CdfCluster)
    }
    
}