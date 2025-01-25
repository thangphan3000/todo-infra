# What I learn through this repo

## Generate key pair for servers

```bash
ssh-keygen -t rsa -b 4096 -C "thangphan.onthego@gmail.com"
```

## If we use variables in terraform

- The terraform plan command will require we input the value for those variables

> NOTES: if we fullfil default value for a variable that variable will not
> require us to input the values in the command: `terraform plan` or `terraform plan`

- Load variables in hierarchy: file_name.tfvars -> variable.tf -> main.tf

> NOTES: if file `file_name.tfvars` has some variables that undefined
> or empty string the variable will use the default vale declare in the variable block otherwise use the value from file `file_name.tfvars`

## Plan/ Apply terraform infra with specific .tfvars file

```bash
terraform plan --var-file 'terraform-dev.tfvars'
```

- When destroy the resources we do not need the file `terraform-dev.tfvars`
