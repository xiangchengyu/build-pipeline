param location string
param namePrefix string


var name = '${namePrefix}${uniqueString(resourceGroup().id)}'
var subnetName = 'defaultsubnet'
var networkSecurityGroupName = 'default-NSG'
var varpublicIpName ='myPublicIP'

var dnsLabelPrefix = toLower('${name}-ip')

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'nsg-allow-in-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }     
      }

      {
        name: 'nsg-allow-out-445'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '445'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }     
      }
      
    ]
  }
}
resource publicIPName 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: varpublicIpName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.2.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
  
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.2.0.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPName.id
          }
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}



output nicId string = nic.id
output vnetId string = vnet.id
output subnetId string = '${vnet.id}/subnets/${subnetName}'
output subnetName string = subnetName
