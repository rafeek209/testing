variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "public_instance_name" {
  description = "Name of the public EC2 instance"
  type        = string
}

variable "private_instance_name" {
  description = "Name of the private EC2 instance"
  type        = string
}
