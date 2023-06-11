module "custom_vpc_config" {
  source          = "./vpc-module"
  network         = var.network
  tags            = var.tags
  security_groups = var.security_groups
}

resource "aws_key_pair" "connection_key" {
  key_name   = "server_rsa"
  public_key = file(var.login.pub_key)
}

resource "aws_instance" "varnish" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2.varnish.instance_type
  vpc_security_group_ids = [module.custom_vpc_config.vpc.security_group_id[2]]
  subnet_id              = module.custom_vpc_config.vpc.private_subnet_id[0]
  key_name               = aws_key_pair.connection_key.key_name
  root_block_device {
    volume_size = var.ec2.varnish.volume_size
  }

  depends_on = [
    module.custom_vpc_config,
    aws_key_pair.connection_key,
    aws_instance.jump_server,
  ]
  provisioner "file" {
    source      = "./bootstrap/varnish"
    destination = "/tmp/varnish"
    connection {
      type                = "ssh"
      user                = var.login.username
      private_key         = file(var.login.priv_key)
      bastion_host        = aws_instance.jump_server.public_ip
      bastion_user        = var.login.username
      bastion_private_key = file(var.login.priv_key)
      host                = coalesce(self.private_ip)
    }
  }

  tags = {
    Name = "${var.tags.name}_varnish"
    environment : var.tags.environment
  }
}

resource "aws_instance" "magento" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2.magento.instance_type
  vpc_security_group_ids = [module.custom_vpc_config.vpc.security_group_id[2]]
  subnet_id              = module.custom_vpc_config.vpc.private_subnet_id[0]
  key_name               = aws_key_pair.connection_key.key_name

  root_block_device {
    volume_size = var.ec2.magento.volume_size
  }

  depends_on = [
    module.custom_vpc_config,
    aws_key_pair.connection_key,
    aws_instance.jump_server,
  ]

  provisioner "file" {
    source      = "./bootstrap/magento_server"
    destination = "/tmp/margento_bootstrap"
    connection {
      type                = "ssh"
      user                = var.login.username
      private_key         = file(var.login.priv_key)
      bastion_host        = aws_instance.jump_server.public_ip
      bastion_user        = var.login.username
      bastion_private_key = file(var.login.priv_key)
      host                = coalesce(self.private_ip)
    }
  }
  tags = {
    Name = "${var.tags.name}_magento"
    environment : var.tags.environment
  }
}

resource "aws_instance" "jump_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2.jumpserver.instance_type
  vpc_security_group_ids = [module.custom_vpc_config.vpc.security_group_id[0]]
  subnet_id              = module.custom_vpc_config.vpc.public_subnet_id[0]
  key_name               = aws_key_pair.connection_key.key_name
  depends_on             = [module.custom_vpc_config, aws_key_pair.connection_key]

  tags = {
    Name = "${var.tags.name}_jumpserver"
    environment : var.tags.environment
  }
}
