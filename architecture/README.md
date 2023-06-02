# CONFIGURATIONS

## VPC

- 192.100.100.0/24

## Public Subnet

- 192.100.100.128/26
- 192.100.100.192/26

## Private Subnet

- 192.100.100.0/26

## Instance Type

- t3.micro (Jump Server)
- t3.large (Varnish and Magento Server)

## SG Ports

- Jumpserver
  - ingress (ssh 22)
  - egress (ssh 22)
- Magento & Varnish Servers
  - ingress (ssh 22), (http 80)
  - egress (ssh 22), (http 80)
- Magento & Varnish Servers
  - ingress (https 443), (http 80)
  - egress (https 443), (http 80)
