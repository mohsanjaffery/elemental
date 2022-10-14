# elemental
Not a type of cheese

# Local Development

This section details how to run the solution locally and deploy your code
changes from the command line.

## Pre-Requisites

The following dependencies must be installed:

- AWS CLI
- Python >=3.7 and pip
- virtualenv

Once you have installed all pre-requisites, you must run the following command
to create a `virtualenv` and install all dependencies before
commencing development.

```bash
make init
```

This command only needs to be ran once.

## Build and Deploy from Source

To deploy the solution manually from the source to your AWS account, run the
following:

1. Create a S3 bucket
   ```
   $ BUCKET_NAME="your-s3-bucket-name"
   $ REGION="us-east-1"
   $ aws s3 mb s3://${BUCKET_NAME} --region $REGION
   ```

1. Create an `.custom.mk` file and populate it with your own values
   ```
   $ cp .custom.mk.example .custom.mk
   ```
1. Deploy the stack
   ```bash
   make deploy
   ```

This will deploy the Elemental Streaming solution using the AWS CLI profile of the current shell. By default this will be the profile `default`.

### Local Deployment

The following commands are also available:

`deploy-lsoa` This will deploy LiveStreaming on AWS solution only.

`deploy-cfal` This will deploy analytics solution only.

## Contributing

Contributions are more than welcome. Please read the [contributing guidelines](CONTRIBUTING.md).

## Limitations

Lambda functions are hitting allowed limit of 64 characters. To resolve this, use stack name as short as possible. Tested with 3 characters `elm`.

`CloudFrontAccessLogsBucket` bucket used for CloudFront logs has hardcoded value, this helps resolve circular dependency between `TransformPartFn` function and `CloudFrontAccessLogsBucket` resource. However, this can cause failures when trying to deploy solution repeatably in the same account.
Resolution: [TODO] add ${AWS::StackID} pseudo parameter to the name.
