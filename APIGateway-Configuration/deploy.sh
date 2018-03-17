#!/bin/sh

# Paramters
capabilities=""
parameters="parameters.json"
name=`jq -r '.[] | select(.ParameterKey=="Name") | .ParameterValue' $parameters`
profile=${1:-default}
template="template.yml"

# Check if stack exists
aws cloudformation list-stack-resources \
    --profile $profile \
    --stack-name $name &> /dev/null

if [ $? -eq 0 ]; then
# Update the existing stack
    echo "Updating Stack: $name"
    aws cloudformation update-stack \
        --capabilities CAPABILITY_IAM \
        --parameters "file://$parameters" \
        --profile $profile \
        --stack-name $name \
        --tags "Key=Name,Value=$name" \
        --template-body "file://$template"
    aws cloudformation wait stack-update-complete \
        --profile $profile \
        --stack-name $name
else
# create a new stack
    echo "Creating Stack: $name"
    aws cloudformation create-stack \
        --capabilities $capabilities \
        --enable-termination-protection \
        --parameters "file://$parameters" \
        --profile $profile \
        --stack-name $name \
        --tags "Key=Name,Value=$name" \
        --template-body "file://$template"
    aws cloudformation wait stack-create-complete \
        --profile $profile \
        --stack-name $name
fi
