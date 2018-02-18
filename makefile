deprovision:
	aws cloudformation delete-stack --stack-name selenium-grid

provision: secrets-devops-decrypt
	aws cloudformation create-stack --stack-name selenium-grid \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/template.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

reprovision: secrets-devops-decrypt
	aws cloudformation update-stack --stack-name selenium-grid \
		--capabilities CAPABILITY_IAM \
		--template-body file://./aws/cloud-formation/template.yml \
		--parameters file://./aws/cloud-formation/secrets.decrypted.json
	make secrets-devops-clean-up

secrets-devops-clean-up:
	rm -rf ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-decrypt:
	aws kms decrypt --ciphertext-blob fileb://./aws/cloud-formation/secrets.encrypted.txt --output text --query Plaintext | base64 --decode > ./aws/cloud-formation/secrets.decrypted.json

secrets-devops-encrypt:
	aws kms encrypt --key-id $(AWS_DEV_OPS_KEY_TOKEN) --plaintext fileb://./aws/cloud-formation/secrets.decrypted.json --output text --query CiphertextBlob | base64 --decode > ./aws/cloud-formation/secrets.encrypted.txt
