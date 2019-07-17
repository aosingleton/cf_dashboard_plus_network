#!/bin/bash

# create will create stack and update param with update stack
action=$1

currentDate=$(date +"%m%d20%y.%H%M")

# resource variables (s3 bucket name, local CF dir, stack name)
varTempBucket=astempbucket$currentDate
varCFBucketLocation=$PWD/correctYaml
varTempCFStackName=ASTempCFStackName071719

# creating cloudformation bucket
aws s3api create-bucket --bucket $varTempBucket
syncing s3 bucket with local CF directory correctYaml
aws s3 sync $varCFBucketLocation s3://$varTempBucket

echo "...creating parameters file"
echo "
[
    {
        \"ParameterKey\": \"TemplatesDashboard\",
        \"ParameterValue\": \"https://${varTempBucket}.s3.amazonaws.com/quickDashboard.yaml\"
    },
    {
        \"ParameterKey\": \"TemplatesNetwork\",
        \"ParameterValue\": \"https://${varTempBucket}.s3.amazonaws.com/quickNetwork.yaml\"
    }
]
" > parameters.json


echo -e "Creating Demo Dashboard Project Resources. \n"
aws cloudformation $action-stack --stack-name ${varTempCFStackName} --template-body file://$PWD/correctYaml/parentStack.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://parameters.json
