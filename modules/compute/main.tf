provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.mgmt_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  # install the MySQL command-line client
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update",
      "sudo dnf install -y mariadb105"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.bastion_private_key
    host        = self.public_ip
  }

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = "${var.environment}"
  }
}
