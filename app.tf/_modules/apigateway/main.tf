module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = var.aws_api_gateway_rest_api_name
  description   = var.aws_api_gateway_rest_api_description
  protocol_type = var.api_gateway_protocol

  cors_configuration = {
    allow_headers = var.allow_headers
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_domain_name = var.create_domain_name

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  # Authorizer(s)
  authorizers = var.authorizers

  # Routes & Integration(s)
  routes = var.routes

  tags = var.tags
}
