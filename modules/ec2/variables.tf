variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "public_sg_id" { type = string }
variable "private_sg_id" { type = string }
variable "instance_type" { default = "t2.micro" }
variable "key_name" { type = string }