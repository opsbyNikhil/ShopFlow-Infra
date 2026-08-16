locals {
  aws_key_pair = {
    key_name   = "${var.project}-${var.env}-key-${var.number}"
    public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  }
}