EXAMPLE:
module "dns_record" {
  source = "github.com/edwardboucher/terra_reform/modules/dns_record"

  zone_name_pattern = "*.realhandsonlabs.net"
  record_name      = "myapp"
  record_type      = "A"
  record_values    = ["10.0.0.1"]
  record_ttl       = 300
}

#Other
The module requires these variables:
zone_name_pattern: Pattern to match the zone name (e.g., "*.realhandsonlabs.net")
record_name: Name for the DNS record (without the zone name)
record_type: Type of DNS record (A, CNAME, TXT, etc.)
record_values: List of values for the record
record_ttl: Time to live (optional, defaults to 300 seconds)

The module outputs:
record_name: The created DNS record name
record_fqdn: The fully qualified domain name of the record