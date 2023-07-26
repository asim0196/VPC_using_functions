variable "vpc_cidr" {
  type = string
}

variable "vpc_subnet_pub_1"{
    type = list
}

variable "vpc_subnet_pvt_1"{
    type = list
}

variable "vpc_az" {
  type = list
}

variable "Pub_ip" {
    type = bool 
}

variable "Key_name" {
    type = any 
}