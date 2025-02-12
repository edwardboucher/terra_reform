Creates an Elastic Container Registry (ECR) repository with configurable scanning and encryption settings.
Repository
https://github.com/edwardboucher/terra_reform/tree/main/modules/ecr
Usage
hclCopy

module "ecr" {
  source = "github.com/edwardboucher/terra_reform//modules/ecr"

  # Optional configurations
  ecr_scan_on_push    = true        # Enable/disable image scanning on push
  ecr_encryption_type = "AES256"    # Encryption type: "AES256" or "KMS"
}

Requirements
NameVersionterraform>= 0.12.26aws>= 3.0
Providers
NameVersionaws>= 3.0
Resources
NameTypeaws_ecr_repository.ecrresource
Inputs
NameDescriptionTypeDefaultRequiredecr_scan_on_pushEnable image scanning on push for the ECR repositorybooltruenoecr_encryption_typeThe encryption type for the ECR repository (e.g., 'AES256' or 'KMS')string"AES256"no
Outputs
NameDescriptionecr_urlThe URL of the created ECR repository
Example
hclCopymodule "example_ecr" {
  source = "github.com/edwardboucher/terra_reform//modules/ecr"

  ecr_scan_on_push    = true
  ecr_encryption_type = "KMS"
}

output "repository_url" {
  value = module.example_ecr.ecr_url
}
Security Features

Image Scanning: Automatically scan container images for vulnerabilities when pushed to the repository (configurable)
Encryption: Support for both AWS managed encryption (AES256) and AWS KMS encryption

License
This module is released under the MIT License. See the LICENSE file for more details.
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.