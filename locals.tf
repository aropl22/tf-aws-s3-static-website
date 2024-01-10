
locals {
  region = "us-west-1"
  name_managed_by = "Terraform"
  name_stack = "Dev"
  existing_dns_zone = false # use false if zone doesn't exists in Route53
}

# Specify website content types copied to s3 storage

locals {
  content_type_map = {
   "js" = "application/json"
   "html" = "text/html"
   "css"  = "text/css"
   "jpg"  = "image/jpeg"
   "jpeg"  = "image/jpeg"
   "png" = "image/png"
  }
}