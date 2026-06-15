module "resource_groups" {

  source = "./modules/resource-group"

  for_each = var.regions

  name     = "rg-${each.key}-prod"

  location = each.value.location

}
