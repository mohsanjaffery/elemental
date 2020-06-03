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
   
### Forked Projects
List or forked projects

```
https://github.com/mohsanjaffery/live-stream-on-aws.git
https://github.com/mohsanjaffery/amazon-cloudfront-access-logs-queries.git
```

Syncing fork from upstream project

```
git remote add upstream https://github.com/awslabs/live-stream-on-aws.git
git remote set-url --push pr no_push
git remote -v
git fetch upstream
```

### Submodule Projects
The above forked projects are submodules of this project

##### Pulling Submodules into a non-initialised repo

```
$ git submodule init
$ git pull --recurse-submodules
```
##### Pulling Submodules into a previously initialised repo

1. List Submodule folders
```
$ git config --file .gitmodules --get-regexp path | awk '{ print $2 }'
```
1. Pull from within Submodule folders from output of above command
```
$ git pull --recurse-submodules
```

### Building live-stream-on-aws submodule

```$ make build-custom-py```


## Contributing

Contributions are more than welcome. Please read the [contributing guidelines](CONTRIBUTING.md).

## Limitations

Lambda functions are hitting allowed limit of 64 characters. To resolve this, use stack name as short as possible. Tested with 3 characters `elm`.
