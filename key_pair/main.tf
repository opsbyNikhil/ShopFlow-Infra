resource "aws_key_pair" "key-pair" {
  key_name   = var.aws_key_pair.key_name
  public_key = var.aws_key_pair.public_key
}