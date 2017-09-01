# Set a variable resource group name
$ResourceGroupName = ""

# Set variable for subscription name
$SubscriptionName = ""

# Set variable for storage account name
$StorageAccountName = ""

# Set variable for container name
$ContainerName = ""

# Set variable for single blob in container
$BlobName = ""

# Set variable for policy name
$PolicyName = $ContainerName + "policy"

# log in to Azure   
Add-AzureRmAccount

# Set the subscription to use; not necessary if you only have one
Set-AzureRmContext -SubscriptionName $SubscriptionName
 
# Get the access keys for the storage account  
$accountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]

# Create a storage account context  
$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $accountKey

# Get a service SAS token with read permission on a specific blob
# Set token start and end time variables
$TokenStartTime = $((Get-Date).ToUniversalTime().AddHours(-1)).ToString("yyyy-MM-ddTHH:mm:ssZ")
$TokenExpiryTime = $((Get-Date).ToUniversalTime().AddDays(1)).ToString("yyyy-MM-ddTHH:mm:ssZ") 
# Create token and write to screen
$blobTokenUrl = New-AzureStorageBlobSASToken -Container $ContainerName -Blob $BlobName -Context $context -Permission r -StartTime $TokenStartTime -ExpiryTime $TokenExpiryTime -FullUri
Write-Host $blobTokenUrl

# Get an account SAS token with read, write, delete and list access to the blob service and container, and write to screen
$tokenUrl = New-AzureStorageAccountSASToken -Service Blob -ResourceType Service, Container -Context $context -Permission rwdl -StartTime $TokenStartTime -ExpiryTime $TokenExpiryTime -Protocol HttpsOnly
Write-Host $tokenUrl

# Create a read and delete stored access policy for a container  
New-AzureStorageContainerStoredAccessPolicy -Name $ContainerName -Policy $PolicyName -Permission "rd" -StartTime $TokenStartTime -ExpiryTime $TokenExpiryTime -Context $context

# Get a service SAS token based on that policy and write to screen
$containerPolicyTokenUrl = New-AzureStorageContainerSASToken -Name $ContainerName -Policy $PolicyName -Context $context -FullUri
Write-Host $containerPolicyTokenUrl