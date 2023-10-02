variable "client_id"{
  type=string
}
variable "client_secret"{
  type=string
}
variable "subscription_id"{
  type=string
}
variable "tenant_id"{
  type=string
}

variable "convention" {
  type        = string
  description = "Define naming convention"
  default     = "k9s-mcti-lab"
}
variable "resource_group_name" {
   description  = "Name of the resource group in which resources will be created"
   type         = string
   default      = "rg"
}

variable "location" {
   type         =  string
   default      = "Canada Central"
   description  = "Location where resources will be created"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default     = {
      environment = "mcitlab"
   }
}

variable "prefix" {
  type      = string
  default   = "mcit"
}

