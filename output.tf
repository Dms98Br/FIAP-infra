output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

output "web_server_endpoint" {
  value = aws_instance.web_server.public_dns
}

output "db_endpoint" {
  value = aws_db_instance.videotraining.endpoint
}

output "react_endpoint" {
  value = "http://${aws_s3_bucket.minha-react-fiap-poc.bucket}.s3-website-us-east-1.amazonaws.com"
}