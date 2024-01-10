#This example explicitly disables the default S3 bucket security settings. 
#This should be done with caution, as all bucket objects become publicly exposed.

resource "aws_s3_bucket" "s3-web" {
  bucket        = "${var.domain_name}"
  force_destroy = true  #all objects should be deleted from the bucket when the bucket is destroyed 
                        #so that the bucket can be destroyed without error
  tags = {
    ManagedBy = "${local.name_managed_by}"
    Stack     = local.name_stack
  }
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.s3-web.id
  policy = data.aws_iam_policy_document.public_read.json
  depends_on = [aws_s3_bucket_public_access_block.s3-web] #need to disble public access before attempting to add the policy
}


/*
Create policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::BUCKET_ARN/*"
        }
    ]
}
*/

data "aws_iam_policy_document" "public_read" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3-web.arn}/*"]
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-web" {
  bucket = aws_s3_bucket.s3-web.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-web" {
  bucket = aws_s3_bucket.s3-web.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-web" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-web,
    aws_s3_bucket_public_access_block.s3-web
  ]

  bucket = aws_s3_bucket.s3-web.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "s3-web" {
  bucket = aws_s3_bucket.s3-web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "img/"
    }
    redirect {
      replace_key_prefix_with = "images/"
    }
  }
}

resource "aws_s3_object" "provision_website_files" {
  bucket = aws_s3_bucket.s3-web.id
  for_each = fileset("website_files/", "**/*.*")
  key = each.value                        
  source = "website_files/${each.value}" 
  content_type = lookup(local.content_type_map, split(".", "website_files/${each.value}")[1], "text/html")
}