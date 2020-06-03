#!/usr/bin/env bash

set -e

# Import configuration
. ./.lsoa_env

# Install Lambda dependencies
make build-custom-py

printf "\n--> Packaging and uploading templates to the %s S3 bucket ...\n" $BUCKET_NAME

aws --region us-east-1 cloudformation package     --template-file main.json     --s3-bucket mjaffery-aws-templates-us-east-1     --output-template-file packaged.template

aws --region us-east-1 cloudformation deploy --template-file /Users/mjaffery/Downloads/lesson01/packaged.template --stack-name bobo-stack --capabilities CAPABILITY_IAM

aws cloudformation package \
  --template-file ./cfn/main.template \
  --s3-bucket $BUCKET_NAME \
  --s3-prefix $PREFIX_NAME \
  --output-template-file ./cfn/packaged.template \
  --region $AWS_REGION

printf "\n--> Deploying %s template...\n" $STACK_NAME

aws cloudformation deploy \
  --template-file ./cfn/packaged.template \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
