# Deploy AWS Elastic Container Service (ECS) using GitHub Actions and Terraform 

## 1. Installation Process

### 01.

Install Terraform & aws-cli on your Workstation

### 02.

Create a User in AWS IAM for your workstation with the Permissions found in the custom_policy.json file

### 03.

Create Access Key & Secret key for that IAM user and enter them in your workstation with the command:

```
aws configure
```

## 2. Infrastructure Setup (Terraform)

### 01. (Optional)

Create an s3 bucket for storing the Terraform State File

```
aws s3api create-bucket --bucket <your_bucket_name> --region <your_region> --acl private --create-bucket-configuration LocationConstraint=<your_region>
```

Uncomment the lines in terraform/s3.tf file, and edit the details to suit your created bucket 

```
vim terraform/s3.tf
```

### 02.

Navigate to the terraform directory and edit the variables.tf file to suit your enviorment (These components will be created by terraform):

```
vim variables.tf
```


### 03.

Run the following commands to initialize, and apply the terraform files

```
terraform init
terraform apply
```

### 04.

Copy the values displayed at the end of the Terraform creation process.

## 2. Deployment Process (GitHub Actions)

### 01.

Navigate to the .github/workflows directory and edit the aws.yml file. Paste the values you copied from the Terraform output into the appropriate places in the file.

### 02.

Create an AWS user for GitHub with the following permissions:

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"ecr:GetDownloadUrlForLayer",
				"ecr:BatchGetImage",
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetAuthorizationToken",
				"ecr:InitiateLayerUpload",
				"ecr:PutImage",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecs:RegisterTaskDefinition",
				"ecs:DescribeServices",
				"ecs:UpdateService"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Sid": "Statement2",
			"Effect": "Allow",
			"Action": [
				"iam:PassRole"
			],
			"Resource": [
				"arn:aws:iam::<your_account_id>:role/ecs-project-*"
			]
		}
	]
}
```

Go to the GitHub Repository -- > Settings -- > Secrets and variables 

### 03.

Add the following repository secrets in your GitHub repository:
   + AWS_ACCESS_KEY_ID
   + AWS_SECRET_ACCESS_KEY

### 04.

Commit and push the .github/workflows/ecs-task-definition.json file to trigger the GitHub Actions workflow.

### 05.

Browse to the Load Balancer DNS provided at the end of the terraform apply command (ALB-DNS-NAME). You should see "Hello There" from the web server.
