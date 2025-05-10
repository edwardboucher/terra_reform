#Example

module "global_rando" {
  source = "github.com/edwardboucher/terra_reform/modules/global_constants"
  
  # Optional: customize these parameters
  string_length         = 4
  include_special_chars = true
  include_upper_chars   = true
  include_lower_chars   = true
  include_numbers       = true
}

# Access the output
output "random_string_result" {
  value = module.global_rando.random_string
}