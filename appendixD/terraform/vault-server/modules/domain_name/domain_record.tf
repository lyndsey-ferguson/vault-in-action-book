provider "godaddy" {
  key    = var.godaddy_api_key
  secret = var.godaddy_api_secret
}

resource "godaddy_domain_record" "record" {
  domain = var.root_domain_name

  record {
    data     = var.root_domain_ips[0]
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }

  dynamic "record" {
    for_each = var.other_records
    content {
      name     = record.value["name"]
      type     = record.value["type"]
      data     = record.value["data"]
      ttl      = record.value["ttl"]
      port     = record.value["port"]
      priority = record.value["priority"]
      weight   = record.value["weight"]
    }
  }

  dynamic "record" {
    for_each = range(var.vault_server_running ? 1 : 0)
    content {
      name = var.vault_server_subdomain
      type = "A"
      data = var.vault_server_ip
      ttl  = 3600
    }
  }

  // specify any A records associated with the domain
  addresses = slice(var.root_domain_ips, 1, length(var.root_domain_ips))
}

