resource "aws_key_pair" "deployer" {
  key_name   = "key_name"
  public_key = "${file("my_key.pub")}"
}


