output "network_security_groups" {
  description = "A map of all network security groups created."
  value       = module.network_security_groups
}

output "route_tables" {
  description = "A map of all route tables created."
  value       = azurerm_route_table.this
}

output "subnets" {
  description = "A map of all subnets created."
  value       = module.subnets
}
