param kvName string

@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param acrName string

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

// azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled    
  }
}

resource kvAdminUsername 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${kvName}/acrAdminUsername'
  properties: {
    value: acr.listCredentials().username
  }
}

resource kvAdminPassword 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${kvName}/acrAdminPassword'
  properties: {
    value: acr.listCredentials().passwords[0].value
  }
}

output acrLoginServer string = acr.properties.loginServer
