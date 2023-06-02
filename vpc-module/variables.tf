variable "network" {
  description = "network properties"
  type = object({
    cidr_block        = string
    Azs               = list(string)
    private_subnet    = list(string)
    public_subnet     = list(string)
    create_default_sg = bool
  })
}

variable "tags" {
  type = object({
    name : string
    environment : string
  })
}

variable "security_groups" {
  type = list(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
}
