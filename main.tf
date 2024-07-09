resource "cloudflare_page_rule" "redirect" {
  for_each = {
    for x in flatten([
      for zone, config in var.zones : [
        for key, redirect in try(coalesce(config.redirects), {}) : merge(redirect, { key = key, zone = zone })
      ] if can(coalesce(config.redirects))
    ]) : "${x.zone}:${x.key}" => x
  }

  zone_id = cloudflare_zone.zone[each.value.zone].id

  target   = replace(each.value.target, "{ZONE}", each.value.zone)
  status   = "active"
  priority = 1

  actions {
    forwarding_url {
      url         = each.value.url
      status_code = try(coalesce(each.value.status), var.defaults.redirects.status)
    }
  }
}

resource "cloudflare_record" "redirect_record" {
  for_each = {
    for x in flatten([
      for zone, config in var.zones : [
        for i, name in try(config.redirects.records, ["@", "www"]) : { name = name, zone = zone }
      ] if can(coalesce(config.redirects))
    ]) : "${x.zone}:${x.name}" => x
  }

  zone_id = cloudflare_zone.zone[each.value.zone].id
  name    = each.value.name
  type    = "A"
  value   = "192.0.2.1"

  comment = "proxy for redirect"
  ttl     = 1 # auto
  proxied = true
}

resource "cloudflare_zone" "zone" {
  account_id = var.account_id

  for_each   = var.zones
  zone       = each.key
  jump_start = try(coalesce(each.value.jump_start), var.defaults.jump_start)
  plan       = try(coalesce(each.value.plan), var.defaults.plan)
}

resource "cloudflare_zone_dnssec" "dnssec" {
  for_each = var.zones
  zone_id  = cloudflare_zone.zone[each.key].id
}

resource "cloudflare_zone_settings_override" "settings" {
  for_each = var.zones
  zone_id  = cloudflare_zone.zone[each.key].id

  settings {
    always_online            = try(coalesce(each.value.always_online), var.defaults.always_online) ? "on" : "off"
    always_use_https         = try(coalesce(each.value.always_use_https), var.defaults.always_use_https) ? "on" : "off"
    automatic_https_rewrites = try(coalesce(each.value.automatic_https_rewrites), var.defaults.automatic_https_rewrites) ? "on" : "off"
    brotli                   = try(coalesce(each.value.brotli), var.defaults.brotli) ? "on" : "off"
    browser_check            = try(coalesce(each.value.browser_check), var.defaults.browser_check) ? "on" : "off"
    early_hints              = try(coalesce(each.value.early_hints), var.defaults.early_hints) ? "on" : "off"
    zero_rtt                 = try(coalesce(each.value.zero_rtt), var.defaults.zero_rtt) ? "on" : "off"
    # http2                    = try(coalesce(each.value.http2), var.defaults.http2)  ? "on" : "off"
    http3                    = try(coalesce(each.value.http3), var.defaults.http3) ? "on" : "off"
    email_obfuscation        = try(coalesce(each.value.email_obfuscation), var.defaults.email_obfuscation) ? "on" : "off"
    opportunistic_encryption = try(coalesce(each.value.opportunistic_encryption), var.defaults.opportunistic_encryption) ? "on" : "off"
    hotlink_protection       = try(coalesce(each.value.hotlink_protection), var.defaults.hotlink_protection) ? "on" : "off"
    websockets               = try(coalesce(each.value.websockets), var.defaults.websockets) ? "on" : "off"
    tls_1_3                  = try(coalesce(each.value.tls_1_3), var.defaults.tls_1_3)
    cname_flattening         = try(coalesce(each.value.cname_flattening), var.defaults.cname_flattening)
    security_level           = try(coalesce(each.value.security_level), var.defaults.security_level)

    minify {
      css  = try(coalesce(coalesce(each.value.minify_css)), var.defaults.minify_css) ? "on" : "off"
      js   = try(coalesce(coalesce(each.value.minify_js)), var.defaults.minify_js) ? "on" : "off"
      html = try(coalesce(coalesce(each.value.minify_html)), var.defaults.minify_html) ? "on" : "off"
    }
  }
}

resource "cloudflare_record" "record" {
  for_each = {
    for x in flatten([
      for zone, config in var.zones : [
        for key, record in try(coalesce(config.records), {}) : merge(record, { key = key, zone = zone })
      ] if can(config.records)
    ]) : "${x.zone}:${x.key}" => x
  }

  zone_id = cloudflare_zone.zone[each.value.zone].id
  name    = replace(coalesce(each.value.name, each.value.key), "@", each.value.zone)
  type    = each.value.type
  value   = each.value.value

  comment  = try(each.value.comment, null)
  ttl      = try(coalesce(each.value.ttl), var.defaults.records.ttl)
  proxied  = contains(["A", "AAAA", "CNAME"], each.value.type) ? try(coalesce(each.value.proxied), var.defaults.records.proxied) : false
  priority = try(coalesce(each.value.priority), var.defaults.records.priority)
}

