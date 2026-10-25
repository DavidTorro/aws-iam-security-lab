# Todas las llamadas van a LocalStack, nunca a una cuenta real de AWS
# LocalStack acepta cualquier credencial, test/test es la convención
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  # Sin cuenta real no hay nada que validar ni metadatos de EC2 que consultar
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam = var.localstack_endpoint
    sts = var.localstack_endpoint
  }
}
