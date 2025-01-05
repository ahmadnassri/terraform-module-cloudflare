variable "account_id" {
  description = "cloudflare account id"
  type        = string
}

variable "defaults" {
  description = "zone defaults"

  type = object({
    jump_start               = optional(bool, true)
    plan                     = optional(string, "free")
    always_online            = optional(bool, true)
    always_use_https         = optional(bool, true)
    automatic_https_rewrites = optional(bool, true)
    brotli                   = optional(bool, true)
    browser_check            = optional(bool, true)
    early_hints              = optional(bool, true)
    zero_rtt                 = optional(bool, true)
    http2                    = optional(bool, true)
    http3                    = optional(bool, true)
    email_obfuscation        = optional(bool, true)
    opportunistic_encryption = optional(bool, true)
    hotlink_protection       = optional(bool, true)
    websockets               = optional(bool, true)
    tls_1_3                  = optional(string, "zrt")
    cname_flattening         = optional(string, "flatten_at_root")
    security_level           = optional(string, "medium")
    minify_css               = optional(bool, true)
    minify_js                = optional(bool, true)
    minify_html              = optional(bool, true)
    redirects = optional(object({
      name       = optional(string)
      target     = optional(string)
      expression = optional(string)
      status     = optional(number, 301)
    }), { status = 301 })
    records = optional(object({
      name     = optional(string)
      type     = optional(string)
      value    = optional(string)
      ttl      = optional(number, 1) # 1 = auto
      proxied  = optional(bool, true)
      priority = optional(number)
    }), { ttl = 1, proxied = true, priority : 0 })
  })
}

variable "zones" {
  description = "zones to manage"

  type = map(object({
    jump_start               = optional(bool)
    plan                     = optional(string)
    always_online            = optional(bool)
    always_use_https         = optional(bool)
    automatic_https_rewrites = optional(bool)
    brotli                   = optional(bool)
    browser_check            = optional(bool)
    early_hints              = optional(bool)
    zero_rtt                 = optional(bool)
    http2                    = optional(bool)
    http3                    = optional(bool)
    email_obfuscation        = optional(bool)
    opportunistic_encryption = optional(bool)
    hotlink_protection       = optional(bool)
    websockets               = optional(bool)
    tls_1_3                  = optional(string)
    cname_flattening         = optional(string)
    security_level           = optional(string)
    minify_css               = optional(bool)
    minify_js                = optional(bool)
    minify_html              = optional(bool)
    redirects = optional(map(object({
      name       = optional(string)
      target     = optional(string)
      expression = optional(string)
      status     = optional(number)
    })))
    records = optional(map(object({
      name     = optional(string)
      type     = optional(string)
      value    = optional(string)
      ttl      = optional(number)
      proxied  = optional(bool)
      priority = optional(number)
    })))
  }))
}

# variable "secrets" {
#   description = "repo secrets"
#   type        = map(any)
# }

# variable "secret_rotation" {
#   description = "repo secret rotation"
#   type        = string
#   default     = "now"
# }
