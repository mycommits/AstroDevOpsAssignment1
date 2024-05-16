# Assignment 1
Write IAAC script for provision of a 3-tier application in AWS.
You can choose terraform or cloudformation to provide the infrastructure.
Your code should provision the following
- [ ] VPC with a public and private subnet.
- [ ] Route tables for each subnet, private subnet shall have a NAT gateway.
- [ ] Application tier and data tier shall be launched in private subnet
- [ ] Web-tier shall be launched in public subnet.
- [ ] Web-tier and application-tier both must have autoscaling enabled and shall be behind an ALB
- [ ] Proper security groups attached across the tiers for proper communication.


Bonus points will be given to the assignments with following items:
- [ ] Proper DNS mappings with a privately hosted zone in Route53 for application and data-tier.
- [ ] IAM roles attached to the application tier to access RDS, cloudwatch and s3 bucket.
- [ ] Key Infra Alert being integrated with SNS and CloudWatch.

## Tool Selection Approach
Based on question definition, we can choose between Terraform and AWS CloudFormation. Here's a brief comparision of them.

1. Provider Support
   - Terraform supports multiple cloud providers (AWS, Azure, Google Cloud, etc.) as well as various other services (like Kubernetes).
   - CloudFormation is tightly integrated with AWS and primarily used for managing AWS resources.
2. State Management
   - Terraform maintains a state file locally or remotely, which tracks the current state of infrastructure. This allows for easier tracking of changes and facilitates collaboration.
   - CloudFormation also maintains a state, but it's managed by AWS and tied to the CloudFormation stack. This state management is automated and less visible to the user.  
3. Execution and Deployment
   - Terraform follows a plan-apply workflow. Users create an execution plan to preview changes before applying them.
   - CloudFormation follows a create-update-delete workflow. Users define a template and AWS handles the execution, automatically managing resource creation, updates, and deletions.
4. Maturity and Community
   - Terraform has been around longer and has a mature ecosystem with a large community contributing modules and providing support.
   - CloudFormation is AWS's native infrastructure as code tool and benefits from deep integration with AWS services, but its community and ecosystem are primarily focused on AWS.
5. Automation and Tooling
   - Terraform's ecosystem includes a wide range of community-contributed modules and plugins, which can accelerate development by providing pre-built configurations for common infrastructure patterns.
   - CloudFormation benefits from AWS's extensive service offerings and integrations, enabling developers to leverage AWS-native tools and services for streamlined development workflows.

## VPC IP Planning
When sizing a Virtual Private Cloud (VPC), careful consideration must be given to the specific requirements of each tier – web, application, and data – as well as factors such as anticipated traffic volume, scalability needs, and security requirements. The following questions can be a good starting point.
- How many availability zones failures have to be tolerated?
- How many availability zones exist in the selected region?
- How many subnets does the application need in each tier?
- How many IP addresses are required for the entire application?
- What's the estimated growth rate for the application?
- Which range of IP addresses should be avoided due to being reserved, used for on-premises infrastructure, integrated with third-party systems and so on?

Here are some pre-defined suggestions.

| VPC Size | Netmask | Subnet Size | Hosts/Subnets | Subnets/VPC | Total IPs |
|----------|---------|-------------|---------------|-------------|-----------|
| Micro    | /24     | /27         | 27            | 8           | 216       |
| Small    | /21     | /24         | 251           | 8           | 2008      |
| Medium   | /19     | /22         | 1019          | 8           | 8152      |
| Large    | /18     | /21         | 2043          | 8           | 16344     |
| XLarge   | /16     | /20         | 4091          | 16          | 65456     |

## Details
- In this implementation, I used a collection of Terraform AWS modules supported by the community. These modules are reliable and well-maintained. For example, the VPC module repository has 2.9k stars, 4.3k forks, and had 770,794 downloads just last week. These modules cover all aspects of the requirements for this project.
  
- According to [AWS documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html) on AWS ALB, at least 2 subnets in different availability zones are required. Therefore, contrary to the definition, I provided 2 public and private subnets in different AZs.
  - ```You must select at least two Availability Zone subnets. Each subnet must be from a different Availability Zone.```

- To enhance accessibility to EC2 instances without key pairs, I utilized IAM instance roles with appropriate privileges to grant Session Manager access to the EC2 instances.
  
## Getting Started
Before deployment, check the `variable.tf` file. All configurable parameters are listed there with clear descriptions for each parameter.

### Steps to Deploy
1. **Initialize Terraform**

    Execute the following command to download the required Terraform dependencies:
    ```sh
    terraform init
    ```

2. **Review Execution Plan**

    To check the execution plan, run the following command:
    ```sh
    terraform plan
    ```

3. **Deploy Resources**

    To deploy the resources, run the following command:
    ```sh
    terraform apply
    ```


## Future Recommended Tasks
- HTTP migration to HTTPS
- Terraform backend migration from local to S3
  - Required configuration is provided as comment lines. A DynamoDB table and S3 bucket is required.
- To add monitoring and feedback loop
- Baking golden images for each layer
- Using multiple availability zones to enhance resiliency of the workload