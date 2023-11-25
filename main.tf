resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "WebServer"
  }
}

resource "aws_s3_bucket" "video_storage" {
  bucket = "video-training-storage"
  acl    = "private"
}

resource "aws_rds_instance" "db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "videotrainingdb"
  username             = "admin"
  password             = "yourpassword"
  parameter_group_name = "default.mysql8.0"
}