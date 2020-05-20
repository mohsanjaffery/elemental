#!/usr/bin/env bash

set -e

# Import configuration
. ./.env

# Install Lambda dependencies
pip install -r cfn/cr-media-connect/requirements.txt --target cfn/cr-media-connect -U

printf "\n--> Packaging and uploading templates to the %s S3 bucket ...\n" $BUCKET_NAME

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
