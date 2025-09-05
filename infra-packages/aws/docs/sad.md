# AWS Infrastructure Packages - System Architecture Document

## Overview
*Purpose and scope of AWS infrastructure components*


## Components
- **VPC Modules**
- **Security Groups**
- **IAM Roles**
- **EC2/ECS Modules**

## Interfaces
- **Input Variables**
- **Output Values**
- **Dependencies**

## Deployment
*Deployment process and considerations*

## Version History
| Version | Date       | Author | Changes       |
|---------|------------|--------|---------------|
| 1.0     | 2023-01-01 | Team   | Initial draft |


## Tree

aws/
├── metaflow_batch
│   ├── BUILD
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── tests
│   │   ├── README.md
│   │   └── test.tftest.hcl
│   ├── variables.tf
│   └── versions.tf
├── docs
│   └── sad.md
├── unop_ecr
│   ├── BUILD
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── tests
│   │   ├── README.md
│   │   └── test.tftest.hcl
│   ├── variables.tf
│   └── versions.tf
├── unop_iam
│   ├── BUILD
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── tests
│   │   ├── README.md
│   │   └── test.tftest.hcl
│   ├── variables.tf
│   └── versions.tf
├── README.md
├── unop_s3
│   ├── BUILD
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── tests
│   │   ├── README.md
│   │   └── test.tftest.hcl
│   ├── variables.tf
│   └── versions.tf
├── unop_security_groups
│   ├── BUILD
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   ├── tests
│   │   ├── README.md
│   │   └── test.tftest.hcl
│   ├── variables.tf
│   └── versions.tf
└── vpc_metaflow
    ├── BUILD
    ├── main.tf
    ├── outputs.tf
    ├── README.md
    ├── tests
    │   ├── README.md
    │   └── test.tftest.hcl
    ├── variables.tf
    └── versions.tf

13 directories, 50 files
