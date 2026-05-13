## Pre-requisites

- AWS account
- Terraform installed
- Existing AWS Key Pair

---

Run the script provided in this repository on the VM where you want Vault to be installed through Terraform.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "vault_sg" {
  name        = "vault-security-group"
  description = "Allow SSH and Vault access"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vault Port"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t2.micro"
  key_name               = "vault"
  vpc_security_group_ids = [aws_security_group.vault_sg.id]

  user_data = file("${path.module}/script.sh")

  tags = {
    Name = "Vault Demo"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

If the user_data approach does not work, first create the EC2 instance and then execute the script using Terraform provisioners (file and remote-exec).

This setup installs Vault and performs the Vault + GitHub Actions configuration required to run the ci.yaml workflow automatically on every push to this repository.

Make sure to update:

IP addresses wherever required
AWS Access Key and Secret Key inside script.sh

These credentials are required temporarily so Vault can interact with AWS and complete the initial configuration.
