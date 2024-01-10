## DNS zone doesn't exists - local.existing_dns_zone = false
resource "aws_route53_zone" "main" {
  count = local.existing_dns_zone ? 0 : 1
  name = var.domain_name

  tags = {
    ManagedBy = local.name_managed_by
    Stack     = local.name_stack
  }
}

resource "aws_route53_record" "allias1" {
  count = local.existing_dns_zone ? 0 : 1
  zone_id = aws_route53_zone.main[count.index].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_s3_bucket_website_configuration.s3-web.website_endpoint
    zone_id                = aws_s3_bucket.s3-web.hosted_zone_id
    evaluate_target_health = false
  }
}
## END DNS zone doesn't exists - local.existing_dns_zone = false

## DNS zone exists - local.existing_dns_zone = true
data "aws_route53_zone" "existing" {
   count = local.existing_dns_zone ? 1 : 0
  name = "${var.domain_name}"
}

resource "aws_route53_record" "allias2" {
  count = local.existing_dns_zone ? 1 : 0
  zone_id = data.aws_route53_zone.existing[count.index].zone_id
  name    = "${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_s3_bucket_website_configuration.s3-web.website_endpoint
    zone_id                = aws_s3_bucket.s3-web.hosted_zone_id
    evaluate_target_health = false
  }
}
## END DNS zone exists - local.existing_dns_zone = true