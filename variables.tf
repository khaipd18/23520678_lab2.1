variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "my_ip" {
  type        = string
  description = "Your public IP address in CIDR format (e.g., X.X.X.X/32)"
  default     = "0.0.0.0/0" # Only for testing
}

variable "key_name" {
  type        = string
  description = "Your AWS Key Pair name for SSH access to EC2 instances"
  default     = "nt548-lab1-key" # Must be created in AWS Console before applying Terraform
}