variable "vpc_cidr" {
    type = string 
}

variable "pub_sub_cidr" {
    type = string
}

variable "pvt_sub_cidr" {
    type = string
}

variable "public_ip_enable" {
    type = bool
}

variable "vpc_az" {
    type = list
}

variable "anywhere_cidr" {
    type = string
}

variable "inst_ami" {
    type = string
}

variable "inst_type" {
    type = string
}