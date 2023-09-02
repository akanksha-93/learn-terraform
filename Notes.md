![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/cloudacademy/terraform-aws)

#### Notes
- HCL is declarative rather than procedural language
- Values can be locally defined in 1. main.tf 2. terraform.tfvars 3. environment variables


#### Project Structure

```
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### Description

- `main.tf`: Contains HCL (Hashicorp Language) to define resources
- `variables.tf`: Contains all the defined variables used in main.tf. This is to segregate and maintain all variables separately. That can be reused in  multiple tf files
- `terraform.tfvars`: Contains values of variables
- `output.tf`: Contains log/output that will be printed during terraform apply
