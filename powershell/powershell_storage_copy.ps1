# Subscription to use.
$SubscriptionName = ""

# Name of the resource group.
$ResourceGroupName = ""

# Name of the storage account
$StorageAccountName = ""

# Name of the container we will use
$ContainerName = ""

# Name of a container we will copy our blobs to
$BackupContainer = ""

# Name of a single file to upload
$ImageName = ""

# Path to a single local image
$ImageToUpload = "C:\" + $ImageName

# Local directory containing several photos and files to upload
$ImgDirectory = "C:\"

# Path to a local folder where you will download images
$DestinationFolder = "C:\"

# Log in to Azure RM account
Add-AzureRmAccount

# Select the subscription you want to use; not necessary if you only have one
Get-AzureRmSubscription –SubscriptionName $SubscriptionName | Select-AzureRmSubscription

# Get the Storage account key
$StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]

# Set a context for the Storage account, so it's the one we use
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

# Set the current storage account
Set-AzureRmCurrentStorageAccount -Context $Context

# Create the container and set it to public blob
New-AzureStorageContainer -Name $ContainerName -Permission Blob

# Set the properties for our photos to be the image/jpeg MIME type
$Properties = @{ "ContentType" = "image/jpeg" }

# Upload a single photo to the container (don't prompt for overwrite)
Set-AzureStorageBlobContent -Container $ContainerName -File $ImageToUpload -Properties $Properties -Force

# Upload the image directory to the container (prompt for overwrite)
Get-ChildItem –Path $ImgDirectory -File -Recurse | Set-AzureStorageBlobContent -Container $ContainerName -Properties $Properties

# List all blobs in the container
Get-AzureStorageBlob -Container $ContainerName

# Download all the blobs from the container
# First, get a reference to a list of all blobs in the container
$blobs = Get-AzureStorageBlob -Container $ContainerName

# Create the local destination directory
New-Item -Path $DestinationFolder -ItemType Directory -Force  

# Download blobs into the local destination directory
$blobs | Get-AzureStorageBlobContent –Destination $DestinationFolder

# Get reference to single uploaded photo
$blob = Get-AzureStorageBlob -Container $ContainerName -Blob $ImageName

# Create a snapshot of the single photo
$snap = $blob.ICloudBlob.CreateSnapshot()

# List the snapshots of the single photo
$snaps = Get-AzureStorageBlob -Prefix $ImageName -Container $ContainerName | Where-Object {$_.ICloudBlob.IsSnapshot }
foreach($item in $snaps) { Write-Host $item.Name }

# Copy single uploaded blob to backup container
# Create backup container
New-AzureStorageContainer -Name $BackupContainer -Permission Blob

# Begin async copy
Start-AzureStorageBlobCopy -SrcBlob $ImageName -DestContainer $BackupContainer -SrcContainer $ContainerName

# Delete the single photo; use force to prevent snapshot warning
$blob | Remove-AzureStorageBlob -Force

# Refresh the blobs list
$blobs = Get-AzureStorageBlob -Container $ContainerName

# Copy all remaining blobs to backup directory async
foreach($item in $blobs) {
	Start-AzureStorageBlobCopy -SrcBlob $item.Name -DestContainer $BackupContainer -SrcContainer $ContainerName
}