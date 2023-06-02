# Magento 2 Infrastructure Deployment

This repository contains the code and instructions for deploying a Magento 2 application on AWS using Terraform. This infrastructure consists of three servers: a caching server, a jump server and a server hosting the Magento application. The AWS load balancer acts as the entry point, terminating SSL and handling routing.

## Task Overview

The task involves creating an infrastructure on AWS to host a Magento 2 application. The infrastructure will include two servers: a caching server and a server specifically for hosting the Magento application. The entry point to the infrastructure will be an AWS load balancer responsible for terminating SSL and handling routing. The task requires describing the infrastructure using Terraform as infrastructure as code. The expected outcome is a functional URL where the Magento application can be accessed.

## Layout

The infrastructure layout consists of the following:

1. Three EC2 servers with Ubuntu 20.04 LTS:
   - Varnish server: Acting as a caching server.
   - Magento Server: Used for Magento 2 application.
   - Jump Server: Providing SSH access to the private servers.
2. Self-signed SSL: Generated SSL certificates using openssl.
3. An AWS load balancer was set up acting as the single entry point to the application with terminating SSL and route handling. The load balancer routes all requests to the Varnish server, except for requests starting with `/media/* or /static/*`, which bypasses the Varnish server and goes directly to the Magento application. It uses HTTPS for communication with customers and performs a permanent redirect from HTTP to HTTPS.
4. Terraform is used for infrastructure setup on AWS.

## Technologies Used

### Server Tools Used

- Magento 2
- Nginx v1.18
- PHP 7.4-fpm
- MySQL 8.0
- Elasticsearch 7.10

### AWS Cloud Tools Used

- Route 53
- Application Load Balancer
- Amazon Certificate Manager(ACM)
- EC2 instances
- VPC configurations

### Infrastructure as Code (IAC)

- The infrastructure is described using Terraform version 1.4.6. The linux_amd64 version is used, along with the Terraform AWS provider version 4.67.0.

## Installation

### Terraform

- Clone this Repo. ensure that your credentials are properly set for AWS

```terraform
terraform init
terraform validate
terraform plan -out=magento2.out
terraform apply magento2.out
```

`N/B: Ensure that you check the variabl files for values specific to your deployments*`

### Varnish

- Copy the `installation` script found in your `/tmp/varnish` in to the required directory. Give the script the required permissions and then run:

```bash
sudo ./varnish/installations/installation.sh
```

### Magento

Please refer to the [bootstrap directory](/bootstrap) for the Magento server installation. Please visit: [Magento MarketPlace](<https://account.magento.com/applications/customer/login/?client_id=10906dd964b2dcc6befafab4f567ce6b&redirect_uri=https%3A%2F%2Fmarketplace.magento.com%2Fsso%2Faccount%2FoauthCallback%2F&response_type=code&scope=adobe_profile&state=c50ec9b4208e770cc5c3e37fe369ff11>) to setup your private and public key. follow [How to Setup Access Keys for authentication](https://devdocs.magento.com/guides/v2.3/install-gde/prereq/connect-auth.html) as a guide.

The installation should follow the sequence:

1. Nginx
2. PHP 7.4-fpm
3. MySQL
4. Elasticsearch
5. Magento 2

Note: This scripts are to be run manually and would prompt you to provide the following details:

1. Magento 2 SQL passwords
2. MySQL root password
3. Base URL
4. Admin username, password, and email
5. Magento's Marketplace private and public keys

Feel free to customize the scripts if you require different configurations for setup. **Ensure that the scripts have the appropriate permissions and are run with sudo as they involve installations.**

### Application URL

You can access the deployed Magento2 application at the following URL: <https://testdomainxyz.site/>

## Modifications

### The following Modifications where considered

1. Using a custom VPC module to allow control over the entire VPC network. Allowing for firewall limitations to be set.
2. Jump server to prevent direct access to the application and increase security.
3. Route 53 for custom provisioning.

### The following modifications are out of scope but could be implemented to enhance the infrastructure

1. Monitoring of servers and traffic: This could be handled by various tools, including AWS's built-in monitoring tools or external tools like Zabbix, Prometheus, or Datadog.
2. Improved user management.
3. Implementing CAC for application deployment if the application is scaled up.
4. Using Docker for easier process management.
5. Artifactory so as to manage server installation and protect against untrusted repos.
6. CI/CD to automate full deplouyment of applications.
7. Application firewalls and CDN to prevent DDOS attacks and improve reachability.
8. Architecture management to account for disaster recovery, scalability and reliability
9. Custom tcp ports could be used to improve security

**Please note that this readme provides a high-level overview of the Magento 2 infrastructure deployment. For detailed instructions on code, please refer to the associated files and documentations in this repository.**
