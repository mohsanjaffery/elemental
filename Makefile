SHELL := /bin/bash

#.PHONY : deploy deploy-containers pre-deploy setup test test-cov test-acceptance test-acceptance-cov test-no-state-machine test-no-state-machine-cov test-unit test-unit-cov

CUSTOM_FILE ?= .custom_mk
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

build-lsoa:
	make clean
	mkdir -p .build/artifact .build/source  && cd .build/source ; \
	cp -pR ../../source/live-stream/custom-resource-py/ . ; \
        pip install -r requirements.txt -t . ; \
        zip -q -r9 ../artifact/live-stream.zip *

deploy-lsoa:
	aws --region $(REGION) cloudformation package --template-file cfn/lsoa-template.yaml --s3-bucket $(TEMP_BUCKET) --output-template-file packaged-lsoa.template
	aws --region $(REGION) cloudformation deploy --template-file packaged-lsoa.template --stack-name $(STACK_NAME)-lsoa --capabilities CAPABILITY_IAM

deploy-cfal:
	aws --region $(REGION) cloudformation package --template-file cfn/cfal-template.yaml --s3-bucket $(TEMP_BUCKET) --output-template-file packaged-cfal.template
	aws --region $(REGION) cloudformation deploy --template-file packaged-cfal.template --stack-name $(STACK_NAME)-cfal --capabilities CAPABILITY_IAM

build-all:
	make build-lsoa

deploy:
	make pre-deploy
	make build-lsoa
	make deploy-lsoa
	#make deploy-cfal

clean:
	xargs rm -rf < ci/clean.lst
