# Handbook

## Table of contents

- [Step to debug/ run queries in RDS database through Bastion Host](#How-to-debug-or-run-SQL-queries-in-RDS-database-through-Bastion-Host?)
- [How to resole diff between Terraform State and AWS console(someone modified in console)](#)

## Step to debug/ run queries in RDS database through Bastion Host

### Step 1: Connect to Bastion Host server

```bash
ssh ec2-user@bastion.cozy-todo.click
```

> NOTES: this step require you inputted the private keypair in the ssh-agent.

### Step 2: Get all RDS instances's endpoint

```bash
aws rds describe-db-instances --output json | jq '.DBInstances[].Endpoint.Address'
```

### Step 3: Connect RDS's MySQL prompt use MySQL cli client

- Command structure: -mysql -u <db_username> -p -h <db_host/db_endpoint> -P <db_port> <database_name>

```bash
mysql -u admin -p -h ap-southeast-1.abc.ap-southeast-1.rds.amazonaws.com -P 3306 todo
```

> NOTES:
>
> 1. please make sure that you run this command in the Bastion Host server
> 2. for the RDS's password please contact the administrator

## How to resole diff between Terraform State and AWS console(someone modified in console)

### Show diff

```bash
terraform plan --var-file 'terraform-dev.tfvars' -refresh-only
```
