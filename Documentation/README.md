# 🚀 Terraform AWS Infrastructure Deployment

This project automates the deployment of a scalable and secure AWS infrastructure using Terraform. It provisions a VPC, public and private subnets, an EC2 instance, and sets up monitoring and logging using AWS CloudWatch. Additionally, it includes a CI/CD pipeline using GitHub Actions for automated deployment.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

### 1. **Terraform** 🛠️  
Install Terraform from the [official website](https://www.terraform.io/downloads.html).

### 2. **AWS CLI** 🔑  
Install the AWS CLI from the [official guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

### 3. **IAM Credentials** 🔒  
Create an IAM user with programmatic access and the following permissions:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
   - `CloudWatchFullAccess`
   - `IAMFullAccess`
   - `AmazonSNSFullAccess`

Save the **Access Key ID** and **Secret Access Key** for the next steps.

---

## 🛠️ Setup Instructions

### 1. Create AWS Credentials to Use CLI
1. Go to the [AWS IAM Console](https://console.aws.amazon.com/iam/).
2. Create a new IAM user with programmatic access.
3. Attach the required policies (listed above).
4. Save the **Access Key ID** and **Secret Access Key**.

### 2. Create a Profile in Local AWS CLI
Run the following command to configure your AWS CLI with the IAM credentials:

```bash
aws configure --profile athena
```

- **AWS Access Key ID**: Paste your Access Key ID.
- **AWS Secret Access Key**: Paste your Secret Access Key.
- **Default region name**: Enter `us-east-1` (or your preferred region).
- **Default output format**: Leave blank or enter `json`.

### 3. Execute `create_key.sh` to Create SSH Key
Run the `create_key.sh` script to generate an SSH key pair for connecting to the EC2 instance:

```bash
chmod +x create_key.sh
./create_key.sh
```

This will:
- Create a key pair named `kp-athena`.
- Save the private key (`kp-athena.pem`) in the `~/.ssh/` directory.
- Set the correct permissions for the private key.

### 4. Format Terraform Code
Ensure Terraform code consistency:

```bash
terraform fmt
```

### 5. Initialize Terraform
Set up the Terraform working directory:

```bash
terraform init
```

### 6. Plan the Infrastructure
Review the infrastructure plan before applying changes:

```bash
terraform plan
```

### 7. Deploy the Infrastructure
Execute the following command to create the AWS resources:

```bash
terraform apply
```

Confirm by typing `yes` when prompted.

### 8. Create and Update `.tfvars` File
Modify the `terraform.tfvars` file with your specific values:

```hcl
profile = "athena"       # Your AWS CLI profile name
email   = "your-email@example.com"  # Email for SNS notifications
region  = "us-east-1"    # AWS region to deploy resources
```

---

## 🚀 Deploying the Web Application

Once the infrastructure is provisioned:
- The EC2 instance will be accessible via the public IP.
- The sample web application (`index.html`) will be deployed automatically via GitHub Actions.

---

## 🛑 Destroying the Infrastructure

To avoid unnecessary charges, destroy the infrastructure when you're done:

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.

---

## 📂 Project Structure

```bash
.
├── cloudwatch.tf           # CloudWatch configuration
├── iam.tf                  # IAM roles and policies
├── sns.tf                  # SNS topic configuration
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Terraform variables
├── outputs.tf              # Terraform outputs
├── create_key.sh           # Script to create SSH key
├── index.html              # Sample web application
├── README.md               # Project documentation
└── .gitignore              # Files to ignore in Git
```

---

## 🙏 Acknowledgments

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

Enjoy deploying your infrastructure! 🎉



## Future improvements

- Create modules for each component of the infrastructure
- Create live template for each environment
- Do more dynamic all the values of the infrastructure
- Improve IAM Permissions
- Create a load balancer for more availability
