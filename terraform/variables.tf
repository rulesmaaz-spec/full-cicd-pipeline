variable "key_name" {
  description = "EC2 key pair name (must exist in ap-south-1)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR, e.g. 1.2.3.4/32"
  type        = string
}
