#EXAMPLE
module "newkey" {<br>
  source = "github.com/edwardboucher/terra_reform/modules/keypair"<br>
  key_name = "new_key01"<br>
  algorhitym = "RSA"<br>
  rsa_bits = 4096<br>
  create_ssh_key_file = false<br>
}