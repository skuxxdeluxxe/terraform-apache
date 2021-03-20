variable "aws_region" {
	default = "ap-southeast-2"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = "list"
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "azs" {
	type = "list"
	default = ["ap-southeast-2", "ap-southeast-2"]
}