# Fully automated deployment of a Scalable Web Service

This Proof of Concept was created as part of a task, which requires the creation of a website, which can be used for publishing blogs.

## Requirements
The whole project was built using AWS as the cloud provider and Terraform v0.10.8 as the provisioning tool.

## How to spin up the Environment
The structure of the directory which contains the code is shown below :

```
.
├── README.md
├── main.tf
├── modules
│   ├── network_setup
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── sg_rules
│       ├── main.tf
│       └── variables.tf
├── network.yaml
├── outputs.tf
├── site
│   ├── index.html
│   └── linux.png
├── templates
│   └── httpd_install.sh
├── terraform.tfvars
└── variables.tf
```
The environment is being built on ``` eu-west-2 ``` region, that is in the London region. This can be changed by modifying the region parameter inside the file ``` terraform.tfvars ```.

For storing the AWS credentials, a free tool called aws-vault was used :

[Aws-Vault](https://github.com/99designs/aws-vault)

After the user has setup his profile on the aws-vault tool, he can then run the following commands in the order shown below and spin up the environment:

1. ``` aws-vault exec <name_of_the_profile> -- terraform get ```

2. ``` aws-vault exec <name_of_the_profile> -- terraform init ```

3. ``` aws-vault exec <name_of_the_profile> -- terraform apply ```

After the environment is built the user will have on his terminal as an output, the DNS name of the ELB which he can be used to access the website.

## AWS Infrastructure

The AWS Infrastructure which is used for this PoC contains the following components :
* 1 VPC
* 2 subnets, 1 private and 1 public
* 1 ELB
* 1 NAT Gateway Service (routing the private subnet to 0.0.0.0/0)
* 1 EIP attached to the NAT Gateway
* 1 ASG
* 1 Launch Configuration
* 1 Instance which acts like a bastion server in order to get access on the Web Servers
* 1 S3 bucket which contains the index.html and an image to be served
* The appropriate Security Groups

The main mechanism used for scaling the service is Amazon Autoscaling Group Service :
[Amazon Autoscaling Group](https://docs.aws.amazon.com/autoscaling/latest/userguide/AutoScalingGroup.html).

For the visualization of the Network Topology of the AWS Infrastructure a free tool called drawthe.net was used:

[Drawthe.net](https://github.com/cidrblock/drawthe.net)

The file that describes the Network Topology is called : ```network.yaml``` and is under the root directory of the project.
![Alt text](./network.png?raw=true "AWS Infrastructure")

## Future Improvements
As this project is mainly a PoC there are a lot of improvements that could be done in order to achieve a more efficient result, although General Best Practices were taken into account while building this project. The following tasks could be improved/added in the future:

1. Setup SSL for the Web Servers (Although traffic for HTTPS was taken into consideration)
2. Setup a new NACL for the Subnets instead of using the default one. This would act as an extra layer of security
3. Use proper DNS resolution by utilizing Amazon's Route53 Service
4. Use a CDN Service such as CloudFront in order to make the content available in a much faster manner in all over the world
5. In conjunction with CDN we can also use WAF in the CDN distribution which could act as an extra layer of security (e.g handling easily DDOS attacks etc)
6. Define more specific policies (e.g based on CPU usage) for scaling up/down the Instances
