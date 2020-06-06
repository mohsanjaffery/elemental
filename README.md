# elemental

### Local Deployment

1. Create a S3 bucket
   ```
   $ BUCKET_NAME=""
   $ AWS_REGION="us-east-1"
   $ aws s3 mb s3://${BUCKET_NAME} --region $AWS_REGION
   ```
1. Create an `.env` file and populate it with your own values
   ```
   $ cp .env.example .env
   ```
1. Double check that `deploy.sh` is executable, if not run:
   ```
   $ chmod +x deploy.sh
   ```
1. Run the deployment script
   ```
   $ ./deploy.sh
   ```
   

### Local build - Live Streaming

Create a `.custom_mk` file and populate it with your own values

   ```
   $ cp .custom_mk_sample .custom_mk
   ```


Run `make deploy` to build and deploy the solution



## Contributing

Contributions are more than welcome. Please read the [contributing guidelines](CONTRIBUTING.md).

## Limitations

Lambda functions are hitting allowed limit of 64 characters. To resolve this, use stack name as short as possible. Tested with 3 characters `elm`.
