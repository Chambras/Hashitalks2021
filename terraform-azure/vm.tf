resource "azurerm_public_ip" "kafkaPublicIP" {
  name                = "${var.suffix}-KafkaPublicIP"
  location            = azurerm_resource_group.genericRG.location
  resource_group_name = azurerm_resource_group.genericRG.name
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "kafkaNIC" {
  name                = "${var.suffix}-KafkaNIC"
  location            = azurerm_resource_group.genericRG.location
  resource_group_name = azurerm_resource_group.genericRG.name

  ip_configuration {
    name      = "kafkaServer"
    subnet_id = azurerm_subnet.subnets["headnodes"].id
    #subnet_id                     = data.azurerm_subnet.kafkasubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kafkaPublicIP.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "kafkaServer" {
  name                = "${var.suffix}-KafkaServer"
  resource_group_name = azurerm_resource_group.genericRG.name
  location            = azurerm_resource_group.genericRG.location
  size                = "Standard_DS3_v2"
  admin_username      = var.vmUserName
  #  encryption_at_host_enabled = true
  network_interface_ids = [azurerm_network_interface.kafkaNIC.id, ]

  admin_ssh_key {
    username   = var.vmUserName
    public_key = file(var.sshKeyPath)
  }

  os_disk {
    name                 = "${var.suffix}-kafkaServerosDisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = var.centossku
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.genericSA.primary_blob_endpoint
  }


  # This is to ensure SSH comes up before we run the local exec.
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.kafkaPublicIP.ip_address
      user        = var.vmUserName
      private_key = file(var.sshPrvtKeyPath)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${azurerm_public_ip.kafkaPublicIP.ip_address},' -u ${var.vmUserName} --private-key ${var.sshPrvtKeyPath} ../ansible/KafkaServer/apache_kafka.yml"
  }

  tags = var.tags
}
