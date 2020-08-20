SHELL := /bin/bash

.PHONY : help init deploy deploy-lsoa deploy-cfal test clean
.DEFAULT: help

# Check for .custom.mk file if exists
CUSTOM_FILE ?= .custom.mk
ifneq ("$(wildcard $(CUSTOM_FILE))","")
	include $(CUSTOM_FILE)
else
$(error File `.custom.mk` doesnt exist, please create one.)
endif

help:
	@echo "init 	generate project for local development"
	@echo "deploy 	generate project and deploy stacks"
	@echo "test		run pre-commit checks"
	@echo "clean	delete virtualenv and installed libraries"

# Install your dependencies and git hooks
init: venv
	venv/bin/pre-commit install
	make build-lsoa
	make build-media-connect

# Build and deploy the project
deploy:
	make pre-deploy
	make build-main
	printf "\n--> Deploying %s template...\n" $(STACK_NAME)
	aws cloudformation deploy \
      --template-file ./cfn/packaged.template \
      --stack-name $(STACK_NAME) \
      --region $(REGION) \
      --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

build-main:
	printf "\n--> Packaging and uploading templates to the %s S3 bucket ...\n" $(TEMP_BUCKET)
	aws cloudformation package \
      --template-file ./cfn/main.template \
      --s3-bucket $(TEMP_BUCKET) \
      --s3-prefix $(PREFIX_NAME) \
      --output-template-file ./cfn/packaged.template \
      --region $(REGION)

build-lsoa:
	make clean-lsoa
	mkdir -p .build/artifact .build/source  && cd .build/source ; \
	cp -pR ../../source/live-stream/custom-resource-py/ . ; \
        pip install -r requirements.txt -t . ; \
        zip -q -r9 ../artifact/live-stream.zip *

build-media-connect:
	pip install -r source/cr-media-connect/requirements.txt --target source/cr-media-connect -U

deploy-lsoa:
	aws --region $(REGION) cloudformation package --template-file cfn/lsoa.template --s3-bucket $(TEMP_BUCKET) --output-template-file packaged-lsoa.template
	aws --region $(REGION) cloudformation deploy --template-file packaged-lsoa.template --stack-name $(STACK_NAME)-lsoa --capabilities CAPABILITY_IAM

deploy-cfal:
	aws --region $(REGION) cloudformation package --template-file cfn/cfal.template --s3-bucket $(TEMP_BUCKET) --output-template-file packaged-cfal.template
	aws --region $(REGION) cloudformation deploy --template-file packaged-cfal.template --stack-name $(STACK_NAME)-cfal --capabilities CAPABILITY_IAM

# virtualenv setup
venv: venv/bin/activate

venv/bin/activate: requirements.txt
	test -d venv || virtualenv venv
	. venv/bin/activate; pip install -Ur requirements.txt
	touch venv/bin/activate

clean-lsoa:
	xargs rm -rf < ci/clean.lst

test:
	pre-commit run --all-files

# Clean up local build
clean:
	make clean-lsoa
	rm -rf venv
	find . -iname "*.pyc" -delete
