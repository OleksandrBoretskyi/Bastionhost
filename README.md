# Bastion Host via Terraform

This project demonstrates how to provision a **private EC2 instance** in AWS that is **not publicly accessible**, and can only be reached via a **Bastion (Jump) Host**.

---

## Prerequisites

To run this project, you need to create a `.env` file in the project root directory with your AWS credentials (Terraform will use them to authenticate):


```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Then activate them in your terminal:

```bash
suorce .env
```

## Running the Terraform 

Initialize the project 

```bash
terraform init
```

Before applying see what will be created (changed)

```bash
terraform plan
```

Apply the changes

```bash
terraform apply
```

---

## What Terraform Creates

This setup includes:

- A **VPC** with CIDR block `10.0.0.0/16`
- A **public subnet** (`10.0.1.0/24`) and a **private subnet** (`10.0.2.0/24`)
- An **internet gateway**, attached to the VPC
- A **route table** for the public subnet with a route to the internet
- A **route table** for the private subnet without internet access
- A **bastion host** (EC2 in the public subnet) with a public IP
- A **target private instance** (EC2 in the private subnet) without any public IP
- Security groups:
  - Bastion SG allows SSH from anywhere (`0.0.0.0/0`)
  - Target SG allows SSH **only from the Bastion SG**

This ensures that the target host **cannot be reached from the internet**, but is accessible through the bastion host.

## Outputs

After a successful `terraform apply`, you will see output values:

```bash
bastion_public_ip = (known after apply)
target_host_ip    = (known after apply)
```

## SSH Configuration

In the `~/.ssh/config` configure:

```ssh
Host bastion
    HostName (known after apply)
    User ec2-user
    IdentityFile ~/.ssh/id_rsa

Host target
    HostName (known after apply)
    User ec2-user
    IdentityFile ~/.ssh/id_rsa
    ProxyJump bastion
```

Now you can connect to the private instance with:

```bash
ssh target
```

## Ansible Monitoring

To verify the health and system status of the target EC2 instance, you can use the included Ansible playbook

Add addresses for bastion host and target in `inventory.ini`

Navigate to the `ansible/` directory and run:

```bash
ansible-playbook check.yml
```
This playbook will:

    Retrieve the uptime of the target instance

    Show disk usage on the root partition

    Display the current CPU load average