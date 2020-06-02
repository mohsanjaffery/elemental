SHELL := /bin/bash

pre-deploy:
ifndef TEMP_BUCKET
	$(error TEMP_BUCKET is undefined)
endif
ifndef ADMIN_EMAIL
	$(error ADMIN_EMAIL is undefined)
endif
ifndef SUBNETS
	$(error SUBNETS is undefined)
endif
ifndef SEC_GROUPS
	$(error SEC_GROUPS is undefined)
endif

pre-run:
ifndef ROLE_NAME
	$(error ROLE_NAME is undefined)
endif

setup-predeploy:
	virtualenv venv
	source venv/bin/activate
	pip install cfn-flip==1.2.2

console:
	cd live-stream-on-aws/source/console; \
	npm install; \
	cp ./node_modules/bootstrap/dist/js/bootstrap.min.js ./assets/js/lib/bootstrap.min.js; \
	cp ./node_modules/bootstrap/dist/css/bootstrap.min.css ./assets/css/bootstrap.min.css; \
	cp ./node_modules/popper.js/dist/popper.min.js ./assets/js/lib/; \
	mv ./node_modules/jquery/dist/jquery.min.js ./assets/js/lib/; \
	mv ./node_modules/video.js/dist/video.js ./assets/js/lib/; \
	mv ./node_modules/video.js/dist/video-js.css ./assets/css/; \
	mv ./node_modules/videojs-contrib-hls/dist/videojs-contrib-hls.js ./assets/js/lib/; \
	curl --location http://orange-opensource.github.io/hasplayer.js/1.10.0/hasplayer.min.js --output assets/js/lib/hasplayer.min.js; \
	curl --location https://cdn.dashjs.org/latest/dash.all.min.js --output assets/js/lib/dash.all.min.js; \
	curl --location https://github.com/videojs/videojs-contrib-dash/releases/download/v2.11.0/videojs-dash.js --output assets/js/lib/videojs-dash.js

cr_node:
	mkdir live-stream-on-aws/build/ ; \
	cd live-stream-on-aws/source/custom-resource-js/; \
	rm -rf node_modules/; \
	npm install --production; \
	rm package-lock.json; \
	zip -q -r9 ../../build/custom-resource-js.zip *

cr_python:
	mkdir live-stream-on-aws/build/ ; \
	virtualenv venv && source venv/bin/activate && pip install --upgrade pip; \
	pip install cfn-flip==1.2.2; \
	# cd live-stream-on-aws/source/custom-resource-py/ ; \
	# pip install --upgrade pip
	# pip install -r ./requirements.txt -t . ; \
	# zip -q -r9 ../../build/custom-resource-py.zip *

clean:
	rm -rf live-stream-on-aws/source/console/node_modules live-stream-on-aws/build package-lock.json

