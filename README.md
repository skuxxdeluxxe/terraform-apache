# terraform-apache

This is a small terraform based stack to deploy an apache webserver behind a load balancer

## Prerequisites

- terraform (latest version)
- Create a key pair in AWS called test-deploy. Instances uses this key to ssh in

## How to deploy

Clone the repository
```sh
git clone https://github.com/skuxxdeluxxe/terraform-apache.git
```

Go into the infrastructure directory
```sh
cd terraform-apache
cd infrastructure
```

Run terraform init
```sh
terraform init
```

Run terraform apply to deploy
```sh
terraform apply
```

If you need to take the stack down
```sh
terraform destroy
```