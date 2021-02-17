output "generic_RG" {
  value = azurerm_resource_group.genericRG.name
}

output "kafkaPublicIP" {
  value = azurerm_public_ip.kafkaPublicIP.ip_address
}

output "kafkaPrivateIP" {
  value = azurerm_network_interface.kafkaNIC.private_ip_address
}

output "sshAccess" {
  description = "Command to ssh into the VM."
  sensitive   = false
  value       = <<SSHCONFIG
  ssh ${var.vmUserName}@${azurerm_public_ip.kafkaPublicIP.ip_address} -i ~/.ssh/vm_ssh
  SSHCONFIG
}
/*
output "adlsFyleSytemID" {
  value = azurerm_storage_data_lake_gen2_filesystem.ADLSFileSystemTFMS.id
}

output "vNetID" {
  value = azurerm_virtual_network.genericVNet.id
}

output "subnets" {
  value = {
    for subnet in azurerm_subnet.subnets :
    subnet.name => subnet.address_prefix
  }
}

output "dataBricksSubnets" {
  value = {
    for subnet in azurerm_subnet.dbSubnets :
    subnet.name => subnet.address_prefix
  }
}
*/
output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.databricksWokspace.workspace_url}/"
}
