param serverName string
param databaseName string
param storageAccountResourceId string
param retentionDays int = 90

// Extract storage account name from resourceId
var storageAccountName = last(split(storageAccountResourceId, '/'))

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

resource audit 'Microsoft.Sql/servers/databases/auditingSettings@2021-11-01-preview' = {
  name: '${serverName}/${databaseName}/default'
  properties: {
    state: 'Enabled'
    storageEndpoint: reference(storageAccountResourceId, '2019-04-01').primaryEndpoints.blob
    storageAccountAccessKey: listKeys(storageAccount.id, '2019-04-01').keys[0].value
    retentionDays: retentionDays
    isStorageSecondaryKeyInUse: false
  }
}
