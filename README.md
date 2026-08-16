# ShopFlow Infrastructure — Terraform AWS

Terraform-based AWS infrastructure for the **ShopFlow E-Commerce Microservices Platform**.

This project is created for practicing Infrastructure as Code (IaC), Terraform modules, AWS networking, Auto Scaling, remote state management, and complete infrastructure lifecycle management.

---

## 📌 Project Overview

The ShopFlow infrastructure is provisioned using Terraform on AWS.

The infrastructure includes:

- VPC
- Public and Private Subnets
- Internet Gateway
- Public Route Table
- Private Route Table
- NAT Gateway
- Security Group
- EC2 Key Pair
- Ubuntu AMI Lookup
- EC2 Launch Templates
- Auto Scaling Groups
- Amazon S3
- Terraform Remote State

AWS Region:

```text
ap-southeast-1
```

---

## 🏗️ Architecture

```
                              ┌──────────────────────┐
                              │       INTERNET       │
                              └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   INTERNET GATEWAY   │
                              └──────────┬───────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    │                                         │
                    ▼                                         ▼
          ┌──────────────────────┐                  ┌──────────────────────┐
          │  PUBLIC ROUTE TABLE  │                  │     NAT GATEWAY       │
          └──────────┬───────────┘                  └──────────┬───────────┘
                     │                                         │
                     │                                         ▼
                     │                              ┌──────────────────────┐
                     │                              │ PRIVATE ROUTE TABLE  │
                     │                              └──────────┬───────────┘
                     │                                         │
          ┌──────────┴───────────┐                   ┌─────────┴──────────┐
          │                      │                   │                    │
          ▼                      ▼                   ▼                    ▼
 ┌─────────────────┐    ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
 │ Frontend Subnet │    │ Frontend Subnet │ │ Backend Subnet  │ │ Backend Subnet  │
 │      1a         │    │    1b / 1c      │ │       1a        │ │       1b        │
 └────────┬────────┘    └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
          │                      │                   │                    │
          └──────────┬───────────┘                   └─────────┬──────────┘
                     │                                         │
                     ▼                                         ▼
            ┌─────────────────┐                     ┌─────────────────┐
            │  FRONTEND ASG   │                     │   BACKEND ASG   │
            │ Launch Template │                     │ Launch Template │
            └─────────────────┘                     └─────────────────┘




                         TERRAFORM REMOTE STATE
                                  │
                                  ▼
                         ┌──────────────────┐
                         │   AMAZON S3      │
                         │                  │
                         │ terraform.tfstate│
                         └──────────────────┘
```

> **NAT Gateway placement:** The NAT Gateway sits in the public subnet but is attached to the Internet Gateway on one side and the Private Route Table on the other. Backend (private) subnets route their outbound traffic through it: `Backend Subnet → Private Route Table → NAT Gateway → Internet Gateway → Internet`.

---

## 📂 Project Structure

```
ShopFlow-Infra/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── backend.tf
├── terraform.tfvars
├── .gitignore
├── README.md
│
├── ami/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── subnets/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── internet-gateway/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── route-table/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── nat-gateway/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── security-group/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── key_pair/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── asg/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
└── s3/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## 🔄 Infrastructure Flow

Terraform creates the infrastructure using the following dependency flow:

```
VPC
 │
 ├── Internet Gateway
 │
 ├── Subnets
 │    ├── Frontend Subnets
 │    └── Backend Subnets
 │
 ├── Route Tables
 │    ├── Public Route Table
 │    └── Private Route Table
 │
 ├── NAT Gateway
 │
 └── Security Group
       │
       └── Launch Templates
              │
              └── Auto Scaling Groups
                     │
                     └── EC2 Instances
```

Terraform state is stored separately:

```
Terraform
    │
    ▼
Amazon S3
    │
    └── terraform.tfstate
```

---

## 🌐 VPC

The project creates a VPC with:

**CIDR:** `10.0.0.0/16`

Example:

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "shopflow-dev-vpc-01"
  }
}
```

The VPC provides an isolated networking environment for the ShopFlow application.

---

## 📦 Subnets

### Frontend Subnets

Three public subnets are created.

| Subnet | CIDR | Availability Zone |
|--------|------|-------------------|
| Frontend 1 | 10.0.1.0/24 | ap-southeast-1a |
| Frontend 2 | 10.0.2.0/24 | ap-southeast-1b |
| Frontend 3 | 10.0.3.0/24 | ap-southeast-1c |

Frontend subnets have public IP assignment enabled.

### Backend Subnets

Two private subnets are created.

| Subnet | CIDR | Availability Zone |
|--------|------|-------------------|
| Backend 1 | 10.0.4.0/24 | ap-southeast-1a |
| Backend 2 | 10.0.5.0/24 | ap-southeast-1b |

Backend subnets do not automatically assign public IP addresses.

---

## 🌍 Internet Gateway

The Internet Gateway provides internet connectivity to resources in public subnets.

```
Frontend Subnet
      │
      ▼
Public Route Table
      │
      ▼
Internet Gateway
      │
      ▼
Internet
```

---

## 🛣️ Route Tables

### Public Route Table

The public route table contains:

```
0.0.0.0/0 → Internet Gateway
```

It is associated with the frontend subnets.

### Private Route Table

The private route table sends outbound traffic through the NAT Gateway.

```
Backend Subnet
      │
      ▼
Private Route Table
      │
      ▼
NAT Gateway
      │
      ▼
Internet Gateway
      │
      ▼
Internet
```

This allows private resources to access the internet without requiring public IP addresses.

---

## 🔀 NAT Gateway

The NAT Gateway provides outbound internet access for resources located inside private subnets.

Example:

```
Backend EC2
    │
    ▼
Private Subnet
    │
    ▼
NAT Gateway
    │
    ▼
Internet Gateway
    │
    ▼
Internet
```

> **Important:** NAT Gateway can generate AWS charges. For practice environments, destroy the infrastructure when you are finished.

---

## 🔐 Security Group

The project creates a security group for the ShopFlow application.

Example ports:

```
8000 - 8004  → Backend APIs
5173 - 5177  → Frontend development servers
3306         → MySQL
```

Example architecture:

```
Internet
   │
   ├── 8000-8004 → Backend Services
   │
   └── 5173-5177 → Frontend Services
```

For production, security group rules should be restricted instead of allowing:

```
0.0.0.0/0
```

---

## 🔑 EC2 Key Pair

Terraform creates an EC2 key pair:

```
shopflow-dev-key-01
```

The key pair can be used to connect to EC2 instances using SSH.

Example:

```bash
ssh -i "shopflow.pem" ubuntu@<PUBLIC-IP>
```

---

## 🖼️ AMI Lookup

Terraform dynamically searches for the required Ubuntu AMI instead of hardcoding an AMI ID.

Example:

```hcl
data "aws_ami" "ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

This allows Terraform to select the latest matching Ubuntu AMI.

---

## 🚀 Launch Templates

The project creates two Launch Templates.

**Frontend Launch Template**
```
shopflow-dev-frontend-ec2-01
```

**Backend Launch Template**
```
shopflow-dev-backend-ec2-01
```

Launch Templates define:

- AMI
- Instance type
- Key pair
- Security group
- Network configuration
- Instance tags

---

## ⚖️ Auto Scaling Groups

The project uses Auto Scaling Groups for frontend and backend services.

**Frontend ASG**
```
Frontend ASG
     │
     ├── Frontend EC2
     ├── Frontend EC2
     └── Frontend EC2
```

**Backend ASG**
```
Backend ASG
     │
     ├── Backend EC2
     └── Backend EC2
```

The Auto Scaling Groups use the corresponding Launch Templates.

---

## 🪣 S3 Remote Backend

Terraform state is stored remotely in Amazon S3.

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "shopflow-dev-terraform-state-01"
    key    = "shopflow/dev/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
```

The state is stored as:

```
S3
└── shopflow-dev-terraform-state-01
    └── shopflow/
        └── dev/
            └── terraform.tfstate
```

---

## 🎯 Why Use S3 for Terraform State?

Without remote state:

```
Developer Machine
└── terraform.tfstate
```

With remote state:

```
Developer Machine
       │
       ▼
      S3
       │
       ▼
terraform.tfstate
```

Advantages:

- Centralized Terraform state
- State is not dependent on one machine
- Team members can use the same state
- Infrastructure state can be recovered
- Better state management

---

## 🚀 Terraform Commands

**Initialize Terraform**
```bash
terraform init
```

**Format Terraform Files**
```bash
terraform fmt -recursive
```

**Validate Configuration**
```bash
terraform validate
```

**Create Execution Plan**
```bash
terraform plan
```

**Create Infrastructure**
```bash
terraform apply
```
or:
```bash
terraform apply -auto-approve
```

**Check Terraform State**
```bash
terraform state list
```

**Show Terraform State**
```bash
terraform show
```

**Destroy Infrastructure**
```bash
terraform destroy
```
or:
```bash
terraform destroy -auto-approve
```

---

## ⚠️ Important: Do Not Delete the Terraform State Bucket First

Suppose the infrastructure is running:

```
AWS
│
├── VPC
├── Subnets
├── Security Groups
├── NAT Gateway
├── Launch Templates
├── Auto Scaling Groups
└── EC2 Instances
```

Terraform state is stored in:

```
S3
└── terraform.tfstate
```

If you delete the S3 state bucket:

```
S3
└── ❌ Deleted
```

the AWS infrastructure will **NOT** automatically be deleted.

The infrastructure can continue running.

Therefore:

```
S3 State Bucket       → Deleted
AWS Infrastructure    → Still Running
```

This can cause AWS resources to continue generating charges.

---

## 🚨 What Happens If S3 State Is Deleted?

If the backend bucket is deleted, Terraform may show:

```
Error loading the state:

S3 bucket "shopflow-dev-terraform-state-01" does not exist.
```

For example:

```bash
terraform state list
```

may fail because Terraform cannot access the remote state.

---

## 🛠️ How to Delete Running Resources If S3 Was Deleted

There are three main approaches.

### Option 1 — Recover Terraform State

This is the preferred approach if you have a recovery state file such as:

```
errored.tfstate
```

First recreate/recover the S3 backend.

Then initialize Terraform:

```bash
terraform init
```

Push the recovered state:

```bash
terraform state push .\errored.tfstate
```

Verify:

```bash
terraform state list
```

Then destroy:

```bash
terraform destroy
```

This is the recovery procedure used during this project.

#### 🔄 State Recovery Flow

```
Terraform Destroy
       │
       ▼
S3 Bucket Missing
       │
       ▼
Terraform Cannot Save State
       │
       ▼
errored.tfstate
       │
       ▼
Recover S3 Backend
       │
       ▼
terraform state push errored.tfstate
       │
       ▼
terraform state list
       │
       ▼
terraform destroy
       │
       ▼
AWS Resources Destroyed
```

### Option 2 — Import Existing Resources

If the state file is completely lost, existing AWS resources can be imported into Terraform state.

Example:

```bash
terraform import aws_vpc.example vpc-xxxxxxxx
```

Other resources may also need to be imported:

- VPC
- Subnets
- Route Tables
- Internet Gateway
- NAT Gateway
- Security Groups
- Launch Templates
- Auto Scaling Groups
- etc.

After importing:

```bash
terraform plan
```

Then Terraform can manage those resources again.

### Option 3 — Delete Resources Manually

If Terraform state cannot be recovered and importing is not practical, resources can be deleted manually through AWS.

Typical dependency order:

```
Auto Scaling Groups
        ↓
EC2 Instances
        ↓
Launch Templates
        ↓
NAT Gateway
        ↓
Route Tables
        ↓
Subnets
        ↓
Security Groups
        ↓
Internet Gateway
        ↓
VPC
```

Manual deletion should generally be the last option when Terraform created the infrastructure.

---

## 🔄 Backend Configuration Changes

If the S3 backend is temporarily commented out:

```hcl
# terraform {
#   backend "s3" {
#     bucket = "shopflow-dev-terraform-state-01"
#     key    = "shopflow/dev/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }
```

Terraform detects that the backend configuration has changed.

You may need:

```bash
terraform init -reconfigure
```

If you actually want to migrate existing state between backends:

```bash
terraform init -migrate-state
```

Use these carefully because they have different purposes.

---

## 🧹 Correct Cleanup Process

The recommended process is:

```
1. terraform plan
        ↓
2. terraform destroy
        ↓
3. Verify AWS resources are deleted
        ↓
4. Verify Terraform state
        ↓
5. Keep S3 state bucket if project may be reused
        ↓
6. Delete S3 state bucket only when completely finished
```

Do **NOT** do:

```
Delete S3 State Bucket
        ↓
terraform destroy
```

because Terraform may lose access to its state before it can destroy the infrastructure.

---

## 🔍 Verify VPC Is Deleted

After:

```bash
terraform destroy -auto-approve
```

check the VPC:

```bash
aws ec2 describe-vpcs `
  --filters "Name=tag:Name,Values=shopflow-dev-vpc-01" `
  --region ap-southeast-1
```

Expected result:

```json
{
    "Vpcs": []
}
```

---

## 🔍 Verify Launch Templates

Run:

```bash
aws ec2 describe-launch-templates `
  --region ap-southeast-1 `
  --query "LaunchTemplates[].{Name:LaunchTemplateName,Id:LaunchTemplateId}"
```

The following ShopFlow Launch Templates should no longer exist:

- `shopflow-dev-backend-ec2-01`
- `shopflow-dev-frontend-ec2-01`

---

## 🔍 Verify Subnets

Run:

```bash
aws ec2 describe-subnets `
  --region ap-southeast-1 `
  --filters "Name=vpc-id,Values=<VPC-ID>"
```

The ShopFlow subnets should no longer exist.

---

## 🔍 Verify Terraform State

Run:

```bash
terraform state list
```

After a successful destroy, the Terraform-managed resources should no longer be present.

Then run:

```bash
terraform plan
```

Terraform should show that there is nothing to create if your configuration/state is intentionally empty.

---

## 🧠 Important Terraform Concepts Learned

This project demonstrates:

- Infrastructure as Code
- Terraform Modules
- Terraform Variables
- Terraform Outputs
- Terraform State
- Remote State
- Amazon S3 Backend
- AWS VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- EC2
- AMI Lookup
- Launch Templates
- Auto Scaling Groups
- Infrastructure Dependencies
- Terraform Destroy
- Terraform State Recovery
- State Import
- Backend Reconfiguration

---

## 🔥 Complete Terraform Lifecycle

```
                    ┌─────────────────┐
                    │    Terraform    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │      VPC        │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
        Subnets        Internet Gateway   Security Group
            │
            ▼
       Route Tables
            │
            ▼
       NAT Gateway
            │
            ▼
    Launch Templates
            │
            ▼
    Auto Scaling Groups
            │
            ▼
        EC2 Instances
            │
            ▼
    ShopFlow Services




Terraform State
       │
       ▼
Amazon S3
       │
       ▼
terraform.tfstate
```

---

## 🗑️ Infrastructure Destroy Flow

```
terraform destroy
        │
        ▼
Auto Scaling Groups
        │
        ▼
Launch Templates
        │
        ▼
EC2 / Dependencies
        │
        ▼
NAT Gateway
        │
        ▼
Subnets
        │
        ▼
Security Groups
        │
        ▼
Route Tables
        │
        ▼
Internet Gateway
        │
        ▼
VPC
        │
        ▼
Infrastructure Destroyed
        │
        ▼
Terraform State Updated
        │
        ▼
S3
```

---

## 🏆 Final Architecture

```
                         ┌──────────────────────┐
                         │       INTERNET       │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   INTERNET GATEWAY   │
                         └──────────┬───────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
              ▼                                           ▼
   ┌──────────────────────┐                    ┌──────────────────────┐
   │  PUBLIC ROUTE TABLE  │                    │      NAT GATEWAY      │
   └──────────┬───────────┘                    └──────────┬───────────┘
              │                                           │
              │                                           ▼
              │                                ┌──────────────────────┐
              │                                │ PRIVATE ROUTE TABLE  │
              │                                └──────────┬───────────┘
              │                                           │
       ┌──────┴──────┐                              ┌─────┴─────┐
       ▼             ▼                              ▼           ▼
 ┌──────────┐  ┌──────────┐                  ┌──────────┐ ┌──────────┐
 │ Frontend │  │ Frontend │                  │ Backend  │ │ Backend  │
 │ Subnet 1 │  │ Subnet 2 │                  │ Subnet 1 │ │ Subnet 2 │
 └────┬─────┘  └────┬─────┘                  └────┬─────┘ └────┬─────┘
      │              │                             │            │
      └──────┬───────┘                             └─────┬──────┘
             │                                           │
             ▼                                           ▼
    ┌─────────────────┐                         ┌─────────────────┐
    │  FRONTEND ASG   │                         │   BACKEND ASG   │
    │ Launch Template │                         │ Launch Template │
    └─────────────────┘                         └─────────────────┘




                  ┌──────────────────────────────────┐
                  │        TERRAFORM REMOTE STATE    │
                  │                                  │
                  │              S3                  │
                  │                                  │
                  │  shopflow/dev/terraform.tfstate │
                  └──────────────────────────────────┘
```

---

## ⚠️ Final Reminder

The most important concept from this project:

```
Terraform Configuration
        +
Terraform State
        +
AWS Infrastructure
```

All three work together.

The S3 bucket stores Terraform state. It does not contain or control the actual AWS infrastructure.

Therefore:

```
Deleting S3
    ≠
Deleting AWS Infrastructure
```

Instead:

```
terraform destroy
    =
Delete Terraform-managed AWS Infrastructure
```

So the safest workflow is:

```bash
terraform plan
terraform apply
terraform destroy
```

Keep the S3 state bucket available while Terraform is managing the infrastructure.