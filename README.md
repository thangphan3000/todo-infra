# Todo Infra

Todo Infra is used to provision AWS resources. It's based on vanilla Terraform code.

## Table of contents

- [How to use](#how-to-use)
- [Set up AWS profile locally](#set-up-aws-profile-locally)
- [Development scripts](#development-scripts)
- [Important notes](#important-notes)

## How to use

1. Clone this repo
2. Install Terraform CLI
3. Please add all `*.tfvars` files containing sensitive data to your local working environment. Contact the repository owner or the person responsible for this repository to obtain them

## Set up AWS profile locally

We must configure AWS profile through AWS CLI.

1. Install latest version of AWS CLI
2. Obtain access key, secret key, and session token from AWS portal
3. Configure AWS profile for the current environment

```
[nonprod]
aws_access_key_id = <your-access-key-id>
aws_secret_access_key = <your-secret-access-key>
aws_session_token = <your-session-token>

[prod]
aws_access_key_id = <your-access-key-id>
aws_secret_access_key = <your-secret-access-key>
aws_session_token = <your-session-token>
```

4. The temporary security credentials will be expired an hour so you need to refresh refresh it hourly

## Development scripts

This template provides a handful of scripts to make your dev experience better!

- Navigate to the desired environment
  - `cd nonprod` or `cd prod`
- Initialize Terraform (First-Time setup)
  - `terraform init`
- Run plan for the current directory with a specific profile name
  - `AWS_PROFILE=nonprod terraform plan --var-file <your-file-name>.tfvars`
- Run apply
  - `AWS_PROFILE=nonprod terraform apply --var-file <your-file-name>.tfvars`
- Format `*.tf` files
  - `terraform fmt -recursive`
- Force unlock terraform state. If Terraform halts due to STS (Security Token Service) credentials expiring during an apply operation, you can force-unlock the state using the following command
  - `AWS_PROFILE=nonprod terraform force-unlock <lock-id>`

## Important notes

- Always run `plan` before executing `apply` to review changes and avoid unintended modifications
- Store sensitive data carefully in `.tfvars` file for preventing commit those to the remote repository. Use `.gitignore` to exclude these files from version control
