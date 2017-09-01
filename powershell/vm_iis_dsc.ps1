# Variables for common values
$location = "southcentralus"
$vmName = "dscVM"

# Log in
Add-AzureRmAccount

# Get your resource group name
Get-AzureRmResourceGroup

# Set resource group variable
$resourceGroup = "Enter your resource group name here"

# Set password for VM admin user
$password = ConvertTo-SecureString -String "LinuxAcademy1" -AsPlainText -Force

# Create admin user object for VM
$cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "pinehead", $password

# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name subnet1 -AddressPrefix 10.0.1.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name dscVnet -AddressPrefix 10.0.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name  dnsPip -DomainNameLabel "ladscdemo$(Get-Random)" -AllocationMethod Dynamic -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 80
$allow80 = New-AzureRmNetworkSecurityRuleConfig -Name allow-port-80  -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

# Create an inbound network security group rule for port 3389
$allow3389 = New-AzureRmNetworkSecurityRuleConfig -Name allow-port-3389  -Protocol Tcp -Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name dscNSG -SecurityRules $allow80, $allow3389

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name dscNic -ResourceGroupName $resourceGroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_D2_v2 | Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version latest | Set-AzureRmVMBootDiagnostics -Disable | Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# Specify the DSC script for installing IIS features
$iisSetting = "{ `"ModulesURL`": `"https://azuredevlabscommon.blob.core.windows.net/70533/AzureDSCWeb.zip`", `"configurationFunction`": `"AzureDSCWeb.ps1\\AzureDSCWeb`", `"Properties`": { `"MachineName`": `"$vmName`" } }"

# Install the DSC VM extension using the IIS DSC script
Set-AzureRmVMExtension -ExtensionName "DSC" -ResourceGroupName $resourceGroup -VMName $vmName -Publisher "Microsoft.Powershell" -ExtensionType "DSC" -TypeHandlerVersion 2.19   -SettingString $iisSetting -Location $location