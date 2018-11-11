#
# Connect_Cluster.ps1
#
$ConnectArgs = @{  ConnectionEndpoint = 'sfdevopscluster.westeurope.cloudapp.azure.com:19000';  X509Credential = $True;  StoreLocation = 'CurrentUser';  StoreName = "MY";  ServerCommonName = "sfdevopscluster.westeurope.cloudapp.azure.com";  FindType = 'FindByThumbprint';  FindValue = "35227E876353B6F2BDCD1C2639F08DCF64B6F667"   }
Connect-ServiceFabricCluster @ConnectArgs