@description('Key Vault Name')
param keyVaultName string

@description('Location')
param location string = resourceGroup().location

@description('App Service Principal ID (Managed Identity)')
param principalId string

// Create Key Vault
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
  }
}


// App Service access to secrets
resource kvSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, principalId, '4633458b-17de-408a-b874-0445c86b69e6')
  scope: kv

  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4633458b-17de-408a-b874-0445c86b69e6'
    )

    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
