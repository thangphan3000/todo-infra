# Handbook

## How to debug or run SQL queries in RDS database through Bastion Host?

### Connect to Bastion Host server

```bash
ssh ec2-user@bastion.cozy-todo.click
```

### Get all RDS instances' endpoint

```bash
aws rds describe-db-instances --output json | jq '.DBInstances[].Endpoint.Address'
```

### Connect RDS's MySQL prompt use MySQL cli client

- Command structure: -mysql -u <db_username> -p -h <host/endpoint> -P <db_port> <database_name>

```bash
mysql -u admin -p -h ap-southeast-1.ctcqi66gwi1n.ap-southeast-1.rds.amazonaws.com -P 3306 todo
```

> Notes:
>
> 1. please make sure that you run this command in the Bastion Host server
> 2. for the RDS's password please contact the administrator
