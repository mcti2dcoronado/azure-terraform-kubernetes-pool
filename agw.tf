resource "azurerm_virtual_network" "vnetmcit" {
  name                = "vnetmcit-${var.convention}"
  resource_group_name = azurerm_resource_group.mcit.name
  location            = azurerm_resource_group.mcit.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.mcit.name
  virtual_network_name = azurerm_virtual_network.vnetmcit.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.mcit.name
  virtual_network_name = azurerm_virtual_network.vnetmcit.name
  address_prefixes     = ["10.254.2.0/24"]
}

resource "azurerm_public_ip" "pipmcit" {
  name                = "pip-${var.convention}"
  resource_group_name = azurerm_resource_group.mcit.name
  location            = azurerm_resource_group.mcit.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "agwmcit" {
  for_each            = azurerm_web_application_firewall_policy.awfmcit
  name                = "agw-${var.convention}-${each.key}"
  resource_group_name = azurerm_resource_group.mcit.name
  location            = azurerm_resource_group.mcit.location
  firewall_policy_id  = "${each.key}"    

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pipmcit.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  
  waf_configuration {
    enabled = true
    firewall_mode = "Prevention"
    rule_set_type = "Microsoft_BotManagerRuleSet"
    rule_set_version = 3.1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    firewall_policy_id             = "${each.key}"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}