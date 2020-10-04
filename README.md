# Smart-Apartment-Data-recruitment-task

Infrastructure as Code for Smart Apartment Data recruitment task according to the 
Technical Assessment Document: https://workdrive.zohoexternal.com/external/9bxrYHL77eW-JJod4

The cloud provider is AWS and the pipeline provider is Azure Devops. The whole 
configuration is splitted into two repositories:

- one on Github that keeps the Terraform AWS infrastructure 
  configuration and AWS Lambda code 
- one on Azure Devops that holds the Nginx files deployable via CodeDeploy. 
  The repository is available here: https://dev.azure.com/piotrpalka123/Smart%20Apartment%20Data/_git/smart-apartment-data-codedeploy

Both of these repositories has their own pipelines on Azure Devops:

- Infrastructure: https://dev.azure.com/piotrpalka123/Smart%20Apartment%20Data/_build?definitionId=1
- Nginx files: https://dev.azure.com/piotrpalka123/Smart%20Apartment%20Data/_build?definitionId=2

## Note about the Technical Assessment execution

- VPC is created with two private (with Nat Gateway) and two public (with Internet Gateway) subnets
- subnets are communicating with each other via route tables.
- private subnets have access to the Internet via Nat Gateways
- EC2 instances are running Debian Linux with Nginx on board. The AMI comes from the AWS
  marketplace and is maintained by Bitnami. I decided to use ready solution rather than 
  equipping my EC2 instances with user data cloudinit scripts to save time. 
- EC2 instances are behind the Application Load Balancer.
- EC2 instances are in Auto Scaling Group and they will scale up if the CPU usage will grow above 60%.
- AWS Lambda code is located in `lambda_function_code/` directory
  - it is able to request external webpage via https and displays the response code
  - it also can access internal webpage running on EC2 with Nginx. To test it I just
    hardcoded the ip address of the instance. This solution is good for testing but as
    the EC2 instances' ip addresses are not persistent it will require better solution 
    for production purposes.

- the goal of the Codedeploy deployments is to replace `index.html` file on Nginx instances
  so we can see the result running the Load Balancer uri in the web browser. After the replacement
  the `systemctl` service responsible for nginx daemon will be restarted

## Note about pipelines

To use pipelines with AWS I had to create IAM user with required permissions. Credentials 
are stored as pipelines' secret env variables and are accessible to `aws` command during
pipeline runtime.

## Note about Terraform

Terraform state file is being kept in S3 bucket and the lock state is being stored in DynamoDB table.

## Azure DevOps project

The whole project with repository and pipelines is public and is accessible on 
https://dev.azure.com/piotrpalka123/Smart%20Apartment%20Data