resource "aws_ecr_repository" "java_api" {
  name                 = "java-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "java-api"
  }
}

resource "aws_ecr_repository" "node_frontend" {
  name                 = "node-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "node-frontend"
  }
}

resource "aws_ecr_lifecycle_policy" "java_api" {
  repository = aws_ecr_repository.java_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "node_frontend" {
  repository = aws_ecr_repository.node_frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
      }
    ]
  })
}
