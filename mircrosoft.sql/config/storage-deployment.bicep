param location string = resourceGroup().location
param storageSKU string = 'Standard_LRS'
param environment string = 'dev'
param sasExpiry string = dateTimeAdd(utcNow(), 'P365D')

var storageAccountName = '${environment}connectplusfs'
var containerName = '${environment}connectplusfile'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: toLower(storageAccountName)
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
//    allowBlobPublicAccess: true
    allowBlobPublicAccess: false // Disable public access to blobs and containers
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
      }
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageAccount.name}/default/${containerName}'
  properties: {
    //publicAccess: 'Blob'  // Allows public read access for blobs only
    publicAccess: 'None'  // No public read access to blobs or containers
  }
  dependsOn: [
    storageAccount
  ]
}

// Specify desired permissions
var sasConfig = {
  //signedExpiry: '2025-12-31T00:00:00.0000000Z' //  Specific expiry date
  signedExpiry: sasExpiry   //  1 Year expiry
  signedResourceTypes: 'sco'
  signedPermission: 'rwdl'
  signedServices: 'b'
  signedProtocol: 'https'
}

// Alternatively, we could use listServiceSas function
var sasToken = storageAccount.listAccountSas(storageAccount.apiVersion, sasConfig).accountSasToken
// Connection string based on a SAS token
output connectionStringSAS string = 'BlobEndpoint=${storageAccount.properties.primaryEndpoints.blob};SharedAccessSignature=${sasToken}'
