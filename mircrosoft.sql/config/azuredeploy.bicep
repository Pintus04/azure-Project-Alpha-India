// @secure()
// param sasToken string
param storageSKU string = 'Standard_LRS'
param administratorLogin string = 'administratorLogin'
param administratorLoginPassword string = 'password@123' // Change this to a secure password in production
param environment string = 'dev'
param skuname string = 'S0'
param skutier string = 'Standard'
// param templateLocation string
// param storageConfig object
// param sqlConfig object

var location = resourceGroup().location

// Storage Account
resource storage_account 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  kind: 'StorageV2'
  location: location
  name: toLower('${environment}cpsasqlempover')
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
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
  sku: {
    name: storageSKU
  }
}

// SQL Server
resource sql_server 'Microsoft.Sql/servers@2023-08-01' = {
  name: toLower('${environment}-cpconnectplussqlserver')
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

// SQL Database
resource devsqldatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  name: toLower('${environment}-cpconnectplusdatabase')
  parent: sql_server
  location: location
  sku: {
    name: skuname
    tier: skutier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}
