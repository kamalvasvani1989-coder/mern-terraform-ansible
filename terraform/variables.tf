variable "aws_region" { default = "ap-southeast-2" }
variable "aws_profile" { default = "mern-tf" }
variable "project" { default = "mern-tf" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "private_subnet_cidr" { default = "10.0.2.0/24" }
variable "instance_type" { default = "t3.micro" }
variable "public_key_path" { default = "~/.ssh/mern-tf.pub" }

variable "my_ip" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32 - only this IP can SSH to the web server"
  type        = string
}
