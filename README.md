# Deployes static website hosted in AWS S3 bucket

Must define backend and AWS access keys
Terraform defaults to using the local backend, which stores state as a plain file in the current working directory.

More info:  
https://developer.hashicorp.com/terraform/language/settings/backends/configuration

 Examples:

### Terraform Cloud backend file

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  cloud {
    organization = "YOUR ORGANIZATION NAME"

    workspaces {
      name = "YOUR WORKSPACE NAME"
    }
  }
}
```

### Local Backend

```terraform
terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }
}
```

## Terraform variable definitions (.tfvars) files

To set lots of variables, it's more convenient to specify their values in a variable definitions file (.tfvars or .tfvars.json)
and then specify that file on the command line with -var-file

 Example (terraform.tfvars):

'''terraform
domain_name = "example.com" # configure existing_dns_zone = false if domain zone doesn't exist in Route53
'''
 
