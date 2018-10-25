SHELL=/bin/sh
STACK-NAME=selenium-grid
TEMPLATE=file://./aws/cloud-formation/template.json

deprovision:
	aws cloudformation delete-stack --stack-name $(STACK-NAME)

estimate-cost: secrets-devops-decrypt
	aws cloudformation estimate-template-cost \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

provision: secrets-devops-decrypt
	aws cloudformation create-stack --stack-name $(STACK-NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

reprovision: secrets-devops-decrypt
	aws cloudformation update-stack --stack-name $(STACK-NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

secrets-devops-clean-up:
	rm -rf ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-decrypt:
	aws kms decrypt --ciphertext-blob fileb://./aws/cloud-formation/secrets.encrypted.txt --output text --query Plaintext | base64 --decode > ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-encrypt:
	aws kms encrypt --key-id $(AWS_DEV_OPS_KEY_TOKEN) --plaintext fileb://./aws/cloud-formation/secrets.decrypted.json --output text --query CiphertextBlob | base64 --decode > ./aws/cloud-formation/secrets.encrypted.txt

info:
	aws cloudformation list-stacks --stack-status-filter  CREATE_IN_PROGRESS \
            CREATE_FAILED\
            CREATE_COMPLETE\
            ROLLBACK_IN_PROGRESS\
            ROLLBACK_FAILED\
            ROLLBACK_COMPLETE\
            DELETE_IN_PROGRESS\
            DELETE_FAILED\
            UPDATE_IN_PROGRESS\
            UPDATE_COMPLETE_CLEANUP_IN_PROGRESS\
            UPDATE_COMPLETE\
            UPDATE_ROLLBACK_IN_PROGRESS\
            UPDATE_ROLLBACK_FAILED\
            UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS\
            UPDATE_ROLLBACK_COMPLETE\
            REVIEW_IN_PROGRESS
						# DELETE_COMPLETE

list-instances:
	aws cloudformation list-stack-instances --stack-name $(STACK-NAME)
