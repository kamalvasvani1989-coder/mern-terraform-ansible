data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
  }
  tags = { Name = "${var.project}-web", Role = "web" }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
  }
  tags = { Name = "${var.project}-db", Role = "db" }

  depends_on = [aws_nat_gateway.nat] # needs internet via NAT on first boot
}
