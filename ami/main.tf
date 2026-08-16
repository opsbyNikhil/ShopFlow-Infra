data "aws_ami" "ami" {
  most_recent = true

  owners = [var.ami_info.exist_owner]

  filter {
    name   = "name"
    values = [var.ami_info.exist_ami]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}