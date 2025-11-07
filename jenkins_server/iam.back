resource "aws_iam_role" "bastion_role" {
  name = "BastionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
    }],
  })
}

# 3. Attach the managed SSM policy to the role
resource "aws_iam_role_policy_attachment" "bastion_role_policy_attachment" {
  role = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Create an IAM instance profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "BastionInstanceProfile"
  role = aws_iam_role.bastion_role.name
}
