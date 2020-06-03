#!make
include envfile
export $(shell sed 's/=.*//' envfile)

SHELL := /bin/bash
  
#.PHONY : deploy deploy-containers pre-deploy setup test test-cov test-acceptance test-acceptance-cov test-no-state-machine test-no-state-machine-cov test-unit test-unit-cov

# The name of the virtualenv directory to use
#VENV ?= venv

pre-deploy:
ifndef TEMP_BUCKET
	$(error TEMP_BUCKET is undefined)
endif
ifndef STACK_NAME
	$(error STACK_NAME is undefined)
endif

pre-run:
ifndef ROLE_NAME
	$(error ROLE_NAME is undefined)
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

deploy-cfn:
	aws --region us-east-1 cloudformation package --template-file live-stream-on-aws/deployment/live-streaming-on-aws.yaml --s3-bucket $(TEMP_BUCKET) --output-template-file packaged.template
	aws --region us-east-1 cloudformation deploy --template-file packaged.template --stack-name $(STACK_NAME) --capabilities CAPABILITY_IAM

deploy:
	make pre-deploy
	make build-custom-py
	make deploy-cfn

clean:
	xargs rm -rf < ci/clean.lst
