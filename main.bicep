param vmUsername string
param vmPassword string
param resourceGroupName string
param namePrefix string
param location string = resourceGroup().location

module vnet './vnets/vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup(resourceGroupName)
  params: {
    namePrefix: namePrefix
    location: location
  }
}

module vm './vm/vm.bicep' = {
  name: 'vm'
  scope: resourceGroup(resourceGroupName)
  params: {
    namePrefix: namePrefix
    location: location
    nicId: vnet.outputs.nicId  
    vmUsername: vmUsername
    vmPassword: vmPassword
  }
  dependsOn: [
    vnet
  ]
}
 
output vmName string = vm.name
