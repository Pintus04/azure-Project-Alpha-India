@description('Key Vault Name')
param keyVaultName string

//  @description('Dev Connection String')
//  param devConnectionString string

//  @description('Dev Blob Storage Connection String')
//  param devBlobConnectionString string

// @description('Test Connection String')
// param testConnectionString string

// @description('Test Blob Storage Connection String')
// param testBlobConnectionString string

@description('UAT Connection String')
param uatConnectionString string

@description('UAT Blob Storage Connection String')
param uatBlobConnectionString string

// @description('Prod Connection String')
// param prodConnectionString string


resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}
// ######################################################
// Deploy secrets to Key Vault + Blob Storage Secret in Dev environment
// ######################################################
// resource devSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: '${kv.name}/ConnectionStrings--Dev'
//   properties: {
//     value: devConnectionString
//   }
// }

// // Blob Storage Dev Secret
// resource devBlobSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: '${kv.name}/AzureBlobStorage--ConnectionStrings--Dev'
//   properties: {
//     value: devBlobConnectionString
//   }
// }

// ######################################################
// Deploy secrets to Key Vault + Blob Storage Secret in TEST environment
// ######################################################

// resource testSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: 'ConnectionStrings--Test'
//   parent: kv
//   properties: {
//     value: testConnectionString
//   }
// }

// resource testBlobSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: 'AzureBlobStorage--ConnectionStrings--Test'
//   parent: kv
//   properties: {
//     value: testBlobConnectionString
//   }
// }

// ######################################################
// Deploy secrets to Key Vault + Blob Storage Secret in UAT environment
// ######################################################
resource uatSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${kv.name}/ConnectionStrings--UAT'
  properties: {
    value: uatConnectionString
  }
}

// Blob Storage Dev Secret
resource uatBlobSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${kv.name}/AzureBlobStorage--ConnectionStrings--UAT'
  properties: {
    value: uatBlobConnectionString
  }
}


// // Prod Secret
// resource prodSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: '${kv.name}/ConnectionStrings--Prod'
//   properties: {
//     value: prodConnectionString
//   }
// }
