# xilution-selenium-grid

* Stand up a Selenium Grid in AWS ECS Fargate using Selenium Grid Host and Node Docker images.
* A configurable CloudFormation template is provide along with a Makefile to simplify the provisioning and deprovisioning process.
* Keeps your secrets safe with KMS.
* Grid accessible through: [http://selenium-grid.your-domain.com:4444](http://selenium-grid.your-domain.com:4444)
* Simply follow the instructions below and you'll have a functioning Selenium Grid stood up in no time.

## Inspiration

* https://github.com/nathanpeck/aws-cloudformation-fargate
* https://github.com/SeleniumHQ/docker-selenium

## Assumptions

* These instructions were created for a Mac environment, but could easily be ported to Linux or Windows.

## Set Up

1. [Set up an AWS Account](https://aws.amazon.com/).
1. Install the [AWS CLI](https://aws.amazon.com/cli).
1. Use [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) to create an administrator identity. It's generally bad practice to use your AWS account's root user. 
1. Use [AWS Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) to create a Hosted Zone with a custom domain name.
1. Use [AWS Key Management System](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) to create a dev ops key for encrypting secrets.
1. Add `export AWS_DEV_OPS_KEY_TOKEN=your-aws-dev-ops-kms-key-token` to your `.bash_profile`. Run `source ~/.bash_profile` to add the new environment variable to your current terminal session. This only needs to be done once.
1. Create a file named `secrets.decrypted.json` in `./aws/cloud-formation/` with the following contents.
	``` json
	[
	  {
		"ParameterKey": "DomainName",
		"ParameterValue": "your-domain.com."
	  }
	]
	```
1. Run `make secrets-devops-encrypt` to encrypt the parameters with your key. Make sure that your 

## Operating your Selenium Grid

1. Run `make provision` to stand up your Selenium Grid. Note that it could take up to 10 minutes to stand up the stack.
	* once provisioned, you can view your Selenium Grid Console at: [http://selenium-grid.your-domain.com:4444](http://selenium-grid.your-domain.com:4444)
1. Run `make deprovision` to tear down your Selenium Grid.

**Warning!** Only run the grid while needed. When not in use, I highly recommend that you run the deprovision step. 
Why pay for your new Selenium Grid when you don't need it. Isn't elasticity great!?!

The Selenium Grid can be accessed at: http://selenium-grid.xilution.com

## Contributions

Pull requests are welcome. If you see an opportunity to improve this repo, please share.

## Pay it Forward

If you find the contents of this repo useful, please share your experiences with the boarder community. Thanks!

## Wish List

See repo Issues.
