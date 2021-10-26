param namePrefix string
param location string = resourceGroup().location
param osDiskType string = 'StandardSSD_LRS'
param vmSize string = 'Standard_D2_v3'
param OSVersion string = '2019-Datacenter'
param vmUsername string
param vmPassword string
param nicId string


var vmName = '${namePrefix}Machine'
var storageAccountNamevar = 'bootdiags${uniqueString(resourceGroup().id)}'

//crate the storage account
resource storageAccountName 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountNamevar
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}


// Create the vm
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccountName.properties.primaryEndpoints.blob
      }
    }
  }
}

output id string = vm.id
