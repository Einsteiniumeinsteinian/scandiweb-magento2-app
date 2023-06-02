variable "network" {
  type = object({
    cidr_block        = string
    Azs               = list(string)
    private_subnet    = list(string)
    public_subnet     = list(string)
    create_default_sg = bool
  })
  default = {
    Azs               = ["eu-north-1a", "eu-north-1b"]
    cidr_block        = "192.100.100.0/24"
    private_subnet    = ["192.100.100.0/26"]
    public_subnet     = ["192.100.100.128/26", "192.100.100.192/26"]
    create_default_sg = true
  }
}

# environment
variable "tags" {
  type = object({
    name : string
    environment : string
  })
  default = {
    name        = "scandiweb"
    environment = "test"
  }
}

variable "login" {
  type = object({
    username = string
    pub_key  = string
    priv_key = string
  })
  default = {
    priv_key = "./secrets/ssh/server_rsa.pem"
    pub_key  = "./secrets/ssh/server_rsa.pem.pub"
    username = "ubuntu"
  }
}

variable "domain_setup" {
  description = "all domain and cert properties"
  type = object({
    private_key = string
    cert_body   = string
    domainName  = string
    record      = string
  })
  default = {
    private_key = "./secrets/cert/private.key"
    cert_body   = "./secrets/cert/testDomain.crt"
    domainName  = "testdomanainxyz.site"
    record      = "www.testdomanainxyz.site"

  }
}

variable "ec2" {
  description = "Server Properties"
  type = object({
    magento = object({
      instance_type = string
      volume_size   = string
    }),
    varnish = object({
      instance_type = string
      volume_size   = string
    }),
    jumpserver = object({
      instance_type = string
    })
  })

  default = {
    magento = {
      instance_type = "t3.large"
      volume_size   = 20
    },
    varnish = {
      instance_type = "t3.large"
      volume_size   = 20
    },
    jumpserver = {
      instance_type = "t3.micro"
    }
  }
}
