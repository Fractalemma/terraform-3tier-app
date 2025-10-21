# AWS 3-tier Architeccture using Terraform

## Overall description

This is a TF project to provision the infra for a 3-tier architecture/applicaction:

- Web Tier: internet-facing (EC2s behind an ALB)
- App Tier (backend) (EC2s behind internal ALB)
- Data Tier: RDS database

To meet the HA (High Availability) requirement all tiers are deployed in two AZs

[![alt text](image.png)](https://github.com/aws-samples/aws-three-tier-web-architecture-workshop/raw/main/application-code/web-tier/src/assets/3TierArch.png)
Notes:

- To reduce costs a simple RDS was used instead of Aurora
- A Route53 Record was placed in front of the ALB for the Web Tier

### Internet-facing tier (web applicaction)

- Route53:
  - Domain registration:
    - Manual provision
    - Includes a Public Hosted Zone
  - A Alias record:
    - Points to the Internet Gateway (which is in front of the ALB)
    - Free of cost
- ACM - AWS Certificate Manager - Puclic certificate:
  - Manual provision
  - Pending approval (not included in the current state -> HTTP traffic)
- Internet Gateway:
  - At VPC level
  - Provides internet accesss to the Web Tier
- Application Load Balancer (x2):
  - One for the Web Tier and one in between the Web and App Tier
  - HTTP listener:
    - Points to the target group
  - HTTPS listener (future implementation when ACM Cert is available):
    - Points to the target group
- Auto Scaling Group (x2):
  - One for the Web Tier and one for the App Tier
  - Launch Template for EC2s
  - Deploy in two AZs
  - 1 EC2 per AZ:
    - Capacity:
      - Desired: 2
      - Min: 2
      - Max: 3
  - Attached to ALB: point to ALB's target group
  - Balanced best effort (default)
  - Health checks

### Data tier (database)

- Primary DB (RDS EC2)
- Replica DB (RDS EC2)

Notes:

- 6 Subnets needed:
  - 2 Public Subnets for the Web Tier (internet-facing EC2s)
  - 2 Private Subnets for App Tier (pri-sub-web-a, pri-sub-web-b)
  - 2 Private Subnets for Data Tier (pri-sub-data-a, pri-sub-data-b)
- Everything is inside a VPC exept for the R53 and ACM resources
- 5 Security Groups are needed:
  - For the ALB of the Web Tier
  - For the ALB of the App Tier
  - For the Web Tier (the ASG)
  - For the App Tier (the ASG)
  - For the Data Tier (attached to the RDS deployment)

## Naming conventions

- Files and folders: kabeb-case
- Variables: snake_case
