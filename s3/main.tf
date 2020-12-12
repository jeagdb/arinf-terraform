resource "aws_s3_bucket" "front-app" {
  bucket = "legends-finder-front-app"
  acl = "public-read"

  force_destroy = true

  policy =  <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "PublicReadGetObject",
              "Effect": "Allow",
              "Principal": "*",
              "Action": [
                  "s3:GetObject"
              ],
              "Resource": [
                  "arn:aws:s3:::legends-finder-front-app/*"
              ]
          }
      ]
    }
  EOT

  website {
    index_document = "index.html"
  }
  tags = {
    Name = "bucket-front"
  }
}