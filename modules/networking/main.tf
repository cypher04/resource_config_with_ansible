resource "azurerm_virtual_network" "vnet" {
    name                = "${var.project_name}-vnet-${var.environment}"
    address_space       = var.address_space
    location            = var.location
    resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
    name                 = "${var.project_name}-subnet-vmss-${var.environment}"
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.subnet_prefixes["vmss"]]
}


resource "azurerm_subnet" "bastion_subnet" {
    name                 = "AzureBastionSubnet"
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.subnet_prefixes["bastion"]]

}


resource "azurerm_lb" "lb" {
    name                = "${var.project_name}-lb-${var.environment}"
    location            = var.location
    resource_group_name = var.resource_group
    sku                 = "Standard"

    frontend_ip_configuration {
        name                 = "PublicIPAddress"
        # subnet_id            = var.subnet_ids[0]
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}


resource "azurerm_lb_backend_address_pool" "lbap" {
    name                = "${var.project_name}-lb-backend-pool-${var.environment}"
    loadbalancer_id     = azurerm_lb.lb.id
}


resource "azurerm_lb_probe" "lbprobe" {
    name                = "${var.project_name}-lb-probe-${var.environment}"
    loadbalancer_id     = azurerm_lb.lb.id
    protocol            = "Tcp"
    port                = 80
    interval_in_seconds = 15
    number_of_probes    = 2
  
}


resource "azurerm_lb_rule" "lbr" {
    name                           = "${var.project_name}-lb-rule-${var.environment}"
    loadbalancer_id                = azurerm_lb.lb.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "PublicIPAddress"
    probe_id                       = azurerm_lb_probe.lbprobe.id
}

resource "azurerm_public_ip" "public_ip" {
    name                = "${var.project_name}-public-ip-${var.environment}"
    location            = var.location
    resource_group_name = var.resource_group
    allocation_method   = "Static"
    sku                 = "Standard"

}

resource "azurerm_public_ip" "public_ip_bastion" {
    name                = "${var.project_name}-public-ip-${var.environment}-bastion"
    location            = var.location
    resource_group_name = var.resource_group
    allocation_method   = "Static"
    sku                 = "Standard"

}

resource "azurerm_bastion_host" "bastion" {
    name                = "${var.project_name}-bastion-${var.environment}"
    location            = var.location
    resource_group_name = var.resource_group
    sku = "Standard"
    ip_configuration {
        name                 = "bastion-ip-config"
        subnet_id            = azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.public_ip_bastion.id
    }

    scale_units = 4
  
}






