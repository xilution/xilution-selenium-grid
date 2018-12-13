SHELL=/bin/sh
STACK-NAME=selenium-grid
TEMPLATE=file://./aws/cloud-formation/template.yml
AWS_PROFILE=boso
AWS_DEV_OPS_KEY_TOKEN=87648098-8dce-4df8-a0d6-0238af3e6270


deprovision:
	aws --profile $(AWS_PROFILE) cloudformation delete-stack --stack-name $(STACK-NAME)

estimate-cost: secrets-devops-decrypt
	aws --profile $(AWS_PROFILE) cloudformation estimate-template-cost \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

provision: secrets-devops-decrypt
	aws --profile $(AWS_PROFILE) cloudformation create-stack --stack-name $(STACK-NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

reprovision: secrets-devops-decrypt
	aws --profile $(AWS_PROFILE) cloudformation update-stack --stack-name $(STACK-NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body $(TEMPLATE) \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

secrets-devops-clean-up:
	rm -rf ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-decrypt:
	aws --profile $(AWS_PROFILE) kms decrypt --ciphertext-blob fileb://./aws/cloud-formation/secrets.encrypted.txt --output text --query Plaintext | base64 --decode > ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-encrypt:
	aws --profile $(AWS_PROFILE) kms encrypt --key-id $(AWS_DEV_OPS_KEY_TOKEN) --plaintext fileb://./aws/cloud-formation/secrets.decrypted.json --output text --query CiphertextBlob | base64 --decode > ./aws/cloud-formation/secrets.encrypted.txt

info:
	aws --profile $(AWS_PROFILE) cloudformation list-stacks --stack-status-filter  CREATE_IN_PROGRESS \
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
	aws --profile $(AWS_PROFILE) cloudformation list-stack-instances --stack-name $(STACK-NAME)
