# Application Gateway and Web Application Firewall with Service Fabric Cluster

This repository provides an example how to use Azure Application Gateway as Web Application Firewall in front of Service Fabric applications.

## Service Fabric Management endpoints

Service Fabric has two Tcp endpoints to manage the cluster.
1. Fabric Gateway to manage the cluster and application
2. Fabric Http Gateway to get access to Service Fabric explorer 

In order to keep this endpoints accessible an Azure Load Balancer is used that balances traffic to these endpoints. In the described scenario a public IP is used to get public access to these endpoints. A self signed certificate is used to secure the cluster and to authenticate clients against the management endpoints. 
The endpoints are kept public to get an easy access for the deployment of new applications.
In a more secure scenario an internal load balancer with a private IP should be used.

## Endpoints to applications running on Service Fabric Cluster

The endpoints to applications running on the cluster are routed through an Application Gateway with a Web Application Firewall enabled.

## Scenario Architecture

![architecture](/doc/pics/Architecture.png)

## Setup the cluster

To setup the cluster we need an Azure Resource Group.

``` Powershell
$rg = New-AzureRmResourceGroup -Name MyResourceGroup -Location westeurope
```

To store the cluster certificate and the Administrator password we need an Azure Key Vault.

``` Powershell
$kv = New-AzureRmKeyVault -Name sftestrgkv -ResourceGroupName $rg.ResourceGroupName -Location westeurope -EnabledForDeployment -EnabledForTemplateDeployment
```

After the Key Vault is created we need to set a secret for the Administrator password.

``` Powershell
$pwd = Set-AzureKeyVaultSecret -VaultName $kv.VaultName -Name AdminPassword -SecretValue (ConvertTo-SecureString -String <password> -AsPlainText -Force)
```

Now we need to create a self signed certificate.

``` Powershell
$cert = New-SelfSignedCertificate -DnsName "sftestcluster.westeurope.cloudapp.azure.com" -FriendlyName sftestcluster -CertStoreLocation "Cert:\CurrentUser\My\"
```

Export the certificate

``` Powershell
Export-PfxCertificate -Cert ("Cert:\CurrentUser\My\" + $cert.Thumbprint) -Password (ConvertTo-SecureString -String <password> -AsPlainText -Force) -FilePath C:\Temp\sftestcluster.pfx
```

Store the certificate in the KeyVault

``` Powershell
$kvcert = Import-AzureKeyVaultCertificate -VaultName $kv.VaultName -Name ClusterCertificate -FilePath C:\Temp\sftestcluster.pfx -Password (ConvertTo-SecureString -String <password> -AsPlainText -Force)
```

Now we have setup all things we need to deploy the scenario using an ARM Template. The ARM Template can be found [here](/src/deploy/ServiceFabricAppGtw.Iac/azuredeploy.json)

Replace the parameters in [azuredeploy.parameters.json]((/src/deploy/ServiceFabricAppGtw.Iac/azuredeploy.parameters.json)).
You can find the values in the Powershell variables created above.

``` Powershell
# KeyVault id for admin password
$kv.ResourceId
# Secret name for admin password
$pwd.Name
#Thumpprint for cluster certificate
$cert.Thumbprint
#Source Vault value
$kv.ResourceId
#Cluster certificate url value
$kvcert.SecretId    
```

Now the cluster can be deployed using Azure reource group deployment

``` Powershell
New-AzureRmResourceGroupDeployment -Name Init -ResourceGroupName $rg.ResourceGroupName -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```

## Deploy Sample Application

Coming soon