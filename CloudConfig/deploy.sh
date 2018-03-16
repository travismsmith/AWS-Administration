template="file://template.yml"
parameters="file://parameters.json"
profile="default"
name="cloud-config"
echo Stack Name: $name

STACK=`aws cloudformation list-stack-resources \
    --stack-name $name \
    --profile $profile &> /dev/null`
if [ $? -eq 0 ]; then
    echo Updating Stack
    aws cloudformation update-stack \
        --template-body $template \
        --stack-name $name \
        --parameters $parameters \
        --capabilities CAPABILITY_IAM \
        --profile $profile
    aws cloudformation wait stack-update-complete \
        --stack-name $name \
        --profile $profile

else
    echo Creating Stack
    aws cloudformation create-stack \
        --template-body $template \
        --stack-name $name \
        --parameters $parameters \
        --capabilities CAPABILITY_IAM \
        --profile $profile \

    aws cloudformation wait stack-create-complete \
        --stack-name $name \
        --profile $profile

fi

iam=`aws cloudformation describe-stacks \
    --stack-name $name \
    --query 'Stacks[0].Outputs[?OutputKey==\`IAMRoleArn\`].OutputValue' \
    --output text \
    --profile $profile`
sns=`aws cloudformation describe-stacks \
    --stack-name $name \
    --query 'Stacks[0].Outputs[?OutputKey==\`SNSTopicArn\`].OutputValue' \
    --output text \
    --profile $profile`
s3=`aws cloudformation describe-stacks \
    --stack-name $name \
    --query 'Stacks[0].Outputs[?OutputKey==\`S3BucketName\`].OutputValue' \
    --output text \
    --profile $profile`

echo $iam
echo $sns
echo $s3

aws configservice subscribe --s3-bucket $s3 --sns-topic $sns --iam-role $iam --profile $profile
