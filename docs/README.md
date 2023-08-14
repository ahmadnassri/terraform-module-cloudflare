## Usage

```tf
module "cloudflare" {
  source = "github.com/ahmadnassri/terraform-module-cloudflare"

  account_id = "xxxxx"

  defaults = {
    jump_start = true
    plan       = "free"

    records = {
      ttl      = 1 # auto
      proxied  = true
      priority = null
    }

    always_online            = true
    always_use_https         = true
    automatic_https_rewrites = true
    brotli                   = true
    browser_check            = true
    early_hints              = true
    zero_rtt                 = true
    http2                    = true
    http3                    = true
    email_obfuscation        = true
    opportunistic_encryption = true
    hotlink_protection       = true
    websockets               = true
    tls_1_3                  = "zrt"
    cname_flattening         = "flatten_at_root"
    security_level           = "medium"
    minify_css               = true
    minify_js                = true
    minify_html              = true
  }

  zones = local.data.zones
}

```

## Inputs

| Name         | Type          | Default | Required | Description                |
| ------------ | ------------- | ------- | -------- | -------------------------- |
| `account_id` | `string`      | `-`     | ✅       | Cloudflare account ID      |
| `zones`      | `map(object)` | `{}`    | ✅       | a map of zones to manage   |
| `defaults`   | `object`      | `{}`    | ❌       | default zone configuration |

### `zones`

###### Example

```tf
zones = {
  example.com = {
    brotli         = false
    security_level = "high"
    redirects = {
      all:
        target: "*{ZONE}/*"
        url: https://ahmadnassri.com
    }
    records = {
      "root" = {
        type  = "A"
        name  = "@"
        value = "127.0.0.1"
      }
      "gmail" = {
        type  = "MX"
        name  = "@"
        value = "SMTP.GOOGLE.COM"
      }
    }
  }
}
```

### `zones` and `defaults`

| Property                   | Type     | Default           | Required | Description                                                               |
| -------------------------- | -------- | ----------------- | -------- | ------------------------------------------------------------------------- |
| `jump_start`               | `bool`   | `true`            | ❌       | Automatically scan your DNS records and import them to Cloudflare         |
| `plan`                     | `string` | `free`            | ❌       | one of: `free`, `pro`, `business`, `enterprise`                           |
| `always_online`            | `bool`   | `true`            | ❌       | Automatically serve cached pages if the origin is offline                 |
| `always_use_https`         | `bool`   | `true`            | ❌       | Automatically redirect all visitors to HTTPS                              |
| `automatic_https_rewrites` | `bool`   | `true`            | ❌       | Automatically rewrite HTTP links to HTTPS                                 |
| `brotli`                   | `bool`   | `true`            | ❌       | Enable Brotli compression                                                 |
| `browser_check`            | `bool`   | `true`            | ❌       | Enable Cloudflare's browser integrity check                               |
| `early_hints`              | `bool`   | `true`            | ❌       | Enable HTTP/2 server push                                                 |
| `zero_rtt`                 | `bool`   | `true`            | ❌       | Enable HTTP/3 0-RTT support                                               |
| `http2`                    | `bool`   | `true`            | ❌       | Enable HTTP/2                                                             |
| `http3`                    | `bool`   | `true`            | ❌       | Enable HTTP/3                                                             |
| `email_obfuscation`        | `bool`   | `true`            | ❌       | Automatically obfuscate all email addresses on your website               |
| `opportunistic_encryption` | `bool`   | `true`            | ❌       | Automatically enable Cloudflare for opportunistic encryption              |
| `hotlink_protection`       | `bool`   | `true`            | ❌       | Automatically enable Cloudflare for hotlink protection                    |
| `websockets`               | `bool`   | `true`            | ❌       | Automatically enable Cloudflare for WebSockets                            |
| `tls_1_3`                  | `string` | `zrt`             | ❌       | one of: `on`, `off`, `zrt`                                                |
| `cname_flattening`         | `string` | `flatten_at_root` | ❌       | one of: `flatten_all`, `flatten_at_root`, `flatten_none`                  |
| `security_level`           | `string` | `medium`          | ❌       | one of: `off`, `essentially_off`, `low`, `medium`, `high`, `under_attack` |
| `minify_css`               | `bool`   | `true`            | ❌       | Automatically minify all CSS files for your website                       |
| `minify_js`                | `bool`   | `true`            | ❌       | Automatically minify all JavaScript files for your website                |
| `minify_html`              | `bool`   | `true`            | ❌       | Automatically minify all HTML files for your website                      |
| `records`                  | `object` | `{}`              | ❌       | DNS records to manage                                                     |
| `redirects`                | `object` | `{}`              | ❌       | Redirect Rules to manage                                                  |

### `records`

| Property   | Type   | Default | Required | Description                                                                         |
| ---------- | ------ | ------- | -------- | ----------------------------------------------------------------------------------- |
| `name`     | string | `-`     | ❌       | DNS record name (or @ for the zone apex)                                            |
| `type`     | string | `-`     | ❌       | record type                                                                         |
| `value`    | string | `-`     | ❌       | content for the record                                                              |
| `ttl`      | number | 1       | ❌       | Time To Live (TTL) of the DNS record in seconds. Setting to 1 means 'automatic'     |
| `proxied`  | bool   | true    | ❌       | Whether the record is receiving the performance and security benefits of Cloudflare |
| `priority` | number | `-`     | ❌       | Required for MX, SRV and URI records; unused by other record types                  |

### `redirects`

| Property | Type     | Default | Required | Description                               |
| -------- | -------- | ------- | -------- | ----------------------------------------- |
| `target` | `string` | `-`     | ❌       | The URL pattern targeted by the page rule |
| `url`    | `string` | `-`     | ❌       | The URL pattern to forward to             |
| `status` | `number` | `301`   | ✅       | The HTTP status code to use for the rule  |
