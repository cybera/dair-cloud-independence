tags = {
  Name        = "django-app"
  Environment = "django DAIR test app"
  Terraform   = "true"
}

# Azure specific
# Best prices for B1MS as of june 2019:
#    'East US' < 'West US2' == 'North Central US' < Other US
#    'Canada Central' < 'Canada East'
azure_location = "East US"

name   = "django-app"
domain = "example.com"
