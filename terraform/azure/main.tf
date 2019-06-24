resource "azurerm_resource_group" "django_group" {
  name     = "django_DAIRTerraformGroup"
  location = "${var.azure_location}"

  tags = "${var.tags}"

}

# create a virtual network
resource "azurerm_virtual_network" "django_vn" {
  name                = "django_vn"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.django_group.name}"

  tags = "${var.tags}"
}

# create subnet
resource "azurerm_subnet" "django_subnet" {
  name                 = "django_sub"
  resource_group_name  = "${azurerm_resource_group.django_group.name}"
  virtual_network_name = "${azurerm_virtual_network.django_vn.name}"
  address_prefix       = "10.0.2.0/24"
}

# create public IP
resource "azurerm_public_ip" "django_ips" {
  name                = "django_ip"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.django_group.name}"
  allocation_method   = "Dynamic"

  tags = "${var.tags}"
}


resource "azurerm_network_security_group" "django_nsg" {
  name                = "djangoNetworkSecurityGroup"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.django_group.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Monitoring"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "App"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = "${var.tags}"
}

# create network interface
resource "azurerm_network_interface" "django_nic" {
  name                = "django_tfni"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.django_group.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.django_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.django_ips.id}"
  }
}

# Generate random 8 character strings
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.django_group.name}"
  }

  byte_length = 8
}

# create storage account
resource "azurerm_storage_account" "django_storage" {
  name                     = "django${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.django_group.name}"
  location                 = "${var.azure_location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = "${var.tags}"
}

# create storage container
resource "azurerm_storage_container" "django_storage_container" {
  name                  = "django-vhd"
  resource_group_name   = "${azurerm_resource_group.django_group.name}"
  storage_account_name  = "${azurerm_storage_account.django_storage.name}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.django_storage"]
}

# create virtual machine
resource "azurerm_virtual_machine" "django_vm" {
  name                  = "${var.name}.${var.domain}"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.django_group.name}"
  network_interface_ids = ["${azurerm_network_interface.django_nic.id}"]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "django_osdisk"
    vhd_uri       = "${azurerm_storage_account.django_storage.primary_blob_endpoint}${azurerm_storage_container.django_storage_container.name}/django_osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.name}.${var.domain}"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${file("../../key/id_rsa.pub")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.django_storage.primary_blob_endpoint}"
  }

  tags = "${var.tags}"
}

resource "null_resource" "django" {
  connection {
    user        = "ubuntu"
    host        = "${azurerm_public_ip.django_ips.ip_address}"
    private_key = "${file("../../key/id_rsa")}"
  }

  provisioner "file" {
    source      = "../../app"
    destination = "/home/ubuntu/app"
  }

  provisioner "remote-exec" {
    inline = ["sudo bash /home/ubuntu/app/bootstrap.sh"]
  }
}

output "public_ip" {
  value = "${azurerm_public_ip.django_ips.ip_address}"
}
