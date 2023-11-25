# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4DEHYYMVW6W4AHPV"
  secret_key = "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"
}

#repository for the back container
resource "aws_ecr_repository" "spring_boot_app" {
  name = "spring-boot-app"  # Name this appropriately
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "Uma política de exemplo para demonstrar o Terraform"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
# servidor_web
resource "aws_instance" "web_server" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  tags = {
    Name = "WebServer"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-spring-boot-app"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name  = "spring-boot-app",
    image = "${aws_ecr_repository.spring_boot_app.repository_url}:latest",
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080
    }]
  }])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-spring-boot-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count = 1
   network_configuration {
    subnets = ["subnet-01cc7ef406aa2e2df", "subnet-00fa18c88d9e60140", "subnet-0a996653cfb5608d5", "subnet-0b6a657abef35b680", "subnet-044e11474c732f1e7", "subnet-07fbca7463574d51e"]  // Replace with your actual subnet IDs
    assign_public_ip = "true"                 // Set to "DISABLED" for internal networking only
  }
}

#banco
resource "aws_db_instance" "videotraining" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "123Aa321"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true  // Set to false in production for security reasons
}
