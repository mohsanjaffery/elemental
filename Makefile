SHELL := /bin/bash

#.PHONY : deploy deploy-containers pre-deploy setup test test-cov test-acceptance test-acceptance-cov test-no-state-machine test-no-state-machine-cov test-unit test-unit-cov

CUSTOM_FILE ?= custom.mk
ifneq ("$(wildcard $(CUSTOM_FILE))","")
	include $(CUSTOM_FILE)
endif
  
pre-deploy:
ifndef TEMP_BUCKET
	$(error TEMP_BUCKET is undefined)
endif
ifndef STACK_NAME
	$(error STACK_NAME is undefined)
endif
ifndef REGION
	$(error REGION is undefined)
endif

setup-predeploy:
	virtualenv venv && \
	source venv/bin/activate && \
	pip install --upgrade pip && \
	pip install cfn-flip==1.2.2

build-custom-py:
	make clean
	mkdir live-stream-on-aws/build && cd live-stream-on-aws/build ; \
	cp -pR ../source/custom-resource-py/ . ; \
        pip install -r requirements.txt -t . ; \
        zip -q -r9 custom-resource-py.zip *

deploy-cfn-lsoa:
	aws --region $(REGION) cloudformation package --template-file live-stream-on-aws/deployment/live-streaming-on-aws.yaml --s3-bucket $(TEMP_BUCKET) --output-template-file packaged.template
	aws --region $(REGION) cloudformation deploy --template-file packaged.template --stack-name $(STACK_NAME)-lsoa --capabilities CAPABILITY_IAM

deploy-cfn-cfal:
	aws --region $(REGION) cloudformation package --template-file amazon-cloudfront-access-logs-queries/template.yaml --s3-bucket $(TEMP_BUCKET) --output-template-file packaged-cfal.template
	aws --region $(REGION) cloudformation deploy --template-file packaged-cfal.template --stack-name $(STACK_NAME)-cfal --capabilities CAPABILITY_IAM

deploy:
	make pre-deploy
	make build-custom-py
	make deploy-cfn-lsoa
	make deploy-cfn-cfal

clean:
	xargs rm -rf < ci/clean.lst
