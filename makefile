deprovision-network:
	aws cloudformation delete-stack --stack-name selenium-grid-network

deprovision-service:
	aws cloudformation delete-stack --stack-name selenium-grid-service

provision-network: secrets-devops-decrypt
	aws cloudformation create-stack --stack-name selenium-grid-network \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/fargate-networking-stacks/public-private-vpc.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

provision-service: secrets-devops-decrypt
	aws cloudformation create-stack --stack-name selenium-grid-service \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/service-stacks/private-subnet-public-loadbalancer.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

reprovision-network: secrets-devops-decrypt
	aws cloudformation update-stack --stack-name selenium-grid-network \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/fargate-networking-stacks/public-private-vpc.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

reprovision-service: secrets-devops-decrypt
	aws cloudformation update-stack --stack-name selenium-grid-service \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/service-stacks/private-subnet-public-loadbalancer.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

secrets-devops-clean-up:
	rm -rf ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-decrypt:
	aws kms decrypt --ciphertext-blob fileb://./aws/cloud-formation/secrets.encrypted.txt --output text --query Plaintext | base64 --decode > ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-encrypt:
	aws kms encrypt --key-id 15540342-c7b8-4151-bece-72f7b5f4e7f5 --plaintext fileb://./aws/cloud-formation/secrets.decrypted.json --output text --query CiphertextBlob | base64 --decode > ./aws/cloud-formation/secrets.encrypted.txt
