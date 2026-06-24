variable "project" {
    type = string
}

variable "environment" {
    type = string
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "gw_tags" {
    type = map
    default = {}
}

variable "public_subnet_cidr" {
    type = list
    default = ["10.0.1.0/24", "10.0.2.0/24"]

}
variable "private_subnet_cidr" {
    type = list
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "database_subnet_cidr" {
    type = list
    default = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "vpc_cidr" {
       default = ["10.0.31.0/24"]
}

variable "public_subnet_tags"{
    type = map
    default = {}
}
variable "private_subnet_tags"{
    type = map
    default = {}
}
variable "databse_subnet_tags"{
    type = map
    default = {}
}

variable "public_route_tags" {
    type = map
    default = {}
}
variable "private_route_tags" {
    type = map
    default = {}
}
variable "database_route_tags" {
    type = map
    default = {}
}
variable "eip_tags" {
    type = map 
    default = {}
  
}

variable "nat_tags" {
    default = {}
}

variable "is_peering_required" {
    default = false
    type = bool
}
variable "vpc_peering_tags" {
    default = {}
}