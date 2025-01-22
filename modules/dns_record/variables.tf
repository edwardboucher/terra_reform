variable "zone_name_pattern" {
  description = "Regex pattern to match the Route 53 zone name (e.g. .*\\.realhandsonlabs\\.net)"
  type        = string
}

variable "record_name" {
  description = "DNS record name (without the zone name)"
  type        = string
}

variable "record_type" {
  description = "DNS record type (e.g. A, CNAME, TXT)"
  type        = string
}

variable "record_ttl" {
  description = "Time to live for DNS record"
  type        = number
  default     = 300
}

variable "record_values" {
  description = "List of values for the DNS record"
  type        = list(string)
}