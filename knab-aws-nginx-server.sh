#!/bin/bash

# Define variables
STACK_NAME="KnabAWSNginxStack"
TEMPLATE_FILE="cloudformation-knab-stack.yaml"
REGION="us-east-1"  # Replace with your preferred region

# Echo the initial message
echo "Creating an Nginx server in AWS in progress..."

# Create the CloudFormation stack
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_FILE \
  --capabilities CAPABILITY_IAM \
  --region $REGION

# Wait for the stack to be created
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME \
  --region $REGION

# Fetch the public IP address from the stack output
INSTANCE_PUBLIC_IP=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query "Stacks[0].Outputs[?OutputKey=='InstancePublicIp'].OutputValue" \
  --output text)

# Check if the IP was retrieved successfully
if [ -z "$INSTANCE_PUBLIC_IP" ]; then
  echo "Failed to retrieve the public IP address from the stack output."
  exit 1
fi

# Output the public IP address
echo "Public IP address of the EC2 instance: $INSTANCE_PUBLIC_IP"

# Wait until the Nginx server is ready
echo "Waiting for Nginx server to be ready..."
while ! curl -s "http://$INSTANCE_PUBLIC_IP" > /dev/null; do
  sleep 1
done

# Verify the Nginx server setup
echo "Nginx server is up and running at http://$INSTANCE_PUBLIC_IP"
