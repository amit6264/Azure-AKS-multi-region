resource "azurerm_cdn_frontdoor_profile" "this" {

  name                = var.frontdoor_name

  resource_group_name = var.resource_group_name

  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {

  name = "${var.frontdoor_name}-endpoint"

  cdn_frontdoor_profile_id =
  azurerm_cdn_frontdoor_profile.this.id
}


resource "azurerm_cdn_frontdoor_origin_group" "this" {

  name = "aks-origin-group"

  cdn_frontdoor_profile_id =
  azurerm_cdn_frontdoor_profile.this.id

  session_affinity_enabled = false

  load_balancing {

    sample_size = 4

    successful_samples_required = 3
  }

  health_probe {

    interval_in_seconds = 100

    path = "/"

    protocol = "Https"

    request_type = "GET"
  }
}


resource "azurerm_cdn_frontdoor_origin" "origins" {

  for_each = var.origin_hostnames

  name = "${each.key}-origin"

  cdn_frontdoor_origin_group_id =
  azurerm_cdn_frontdoor_origin_group.this.id

  enabled = true

  host_name = each.value

  http_port  = 80

  https_port = 443

  origin_host_header = each.value

  priority = 1

  weight = 1000

  certificate_name_check_enabled = true
}


resource "azurerm_cdn_frontdoor_route" "this" {

  name = "default-route"

  cdn_frontdoor_endpoint_id =
  azurerm_cdn_frontdoor_endpoint.this.id

  cdn_frontdoor_origin_group_id =
  azurerm_cdn_frontdoor_origin_group.this.id

  cdn_frontdoor_origin_ids = [
    for o in azurerm_cdn_frontdoor_origin.origins :
    o.id
  ]

  forwarding_protocol = "HttpsOnly"

  https_redirect_enabled = true

  patterns_to_match = ["/*"]

  supported_protocols = [
    "Http",
    "Https"
  ]

  link_to_default_domain = true
}


resource "azurerm_cdn_frontdoor_firewall_policy" "this" {

  name = "${var.frontdoor_name}-waf"

  resource_group_name = var.resource_group_name

  sku_name = "Premium_AzureFrontDoor"

  enabled = true

  mode = "Prevention"
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {

  name = "frontdoor-security"

  cdn_frontdoor_profile_id =
  azurerm_cdn_frontdoor_profile.this.id

  security_policies {

    firewall {

      cdn_frontdoor_firewall_policy_id =
      azurerm_cdn_frontdoor_firewall_policy.this.id

      association {

        domain {

          cdn_frontdoor_domain_id =
          azurerm_cdn_frontdoor_endpoint.this.id
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
