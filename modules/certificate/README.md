EXAMPLE:
module base_cert" {
  source = "../modules/certificate"

  acme_email_address = "myemail@gmail.com"
  domain_name = "891377289799.realhandsonlabs.net"
  san_name = "cool-dns-name"
}