//app-service.bicep

@description('Specifies the environment of app service')


param resourceGroupID string = uniqueString(resourceGroup().id) // Generate a unique name for the web app
param env string = 'dev'
param webAppName string = 'connectpluscpbackend' // Generate a unique name for the web app
param location string = resourceGroup().location // Location for all resources
param sku string = 'S1' // Tier of the App Service plan
param windowsFxVersion string = 'dotnet:8' // Runtime stack of the web app
var appServicePlanName = toLower('AppServicePlan-${webAppName}') // Generate a unique name for the App Service plan
var webSiteName = toLower('${env}-dotnet-connectpluscpbackend') // Generate a unique name for the App
var appInsightName = toLower('appi-${env}-${webAppName}')
var logAnalyticsName = toLower('la-${env}-${webAppName}')

// resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
//   name: appServicePlanName
//   location: location
//   sku: {
//     name: sku
//   }
//   kind: 'linux'
//   properties: {
//     reserved: true
//   }
// }

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: webSiteName
  location: location
  kind:'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      publicNetworkAccess: 'Enabled'
      windowsFxVersion: windowsFxVersion
    }
  }
}

resource aspNetCore8Support 'Microsoft.Web/sites/siteextensions@2022-09-01' = {
  parent: appService
  name: 'AspNetCoreRuntime.8.0.x86'
}

resource appServiceLogging 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    WEBSITE_RUN_FROM_PACKAGE: 1
  }
  dependsOn: [
    appServiceSiteExtension
  ]
}

resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2022-09-01' = {
  parent: appService
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
  dependsOn: [
    appInsights
  ]
}

resource appServiceAppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appService
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 40
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'string'
  tags: {
    displayName: 'AppInsight'
    ProjectName: webAppName
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: {
    displayName: 'Log Analytics'
    ProjectName: webAppName
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 120
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}
