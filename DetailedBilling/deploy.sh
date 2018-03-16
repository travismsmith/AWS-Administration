profile=${1:-default}
template="file://template.yml"
name="detailed-billing"

echo Stack Name: $name

STACK=`aws cloudformation list-stack-resources \
    --stack-name $name \
    --profile $profile &> /dev/null`

if [ $? -eq 0 ]; then
    echo Updating Stack
    aws cloudformation update-stack \
        --template-body $template \
        --stack-name $name \
        --profile $profile
    aws cloudformation wait stack-update-complete \
        --stack-name $name \
        --profile $profile
else
    echo Creating Stack
    aws cloudformation create-stack \
        --template-body $template \
        --stack-name $name \
        --enable-termination-protection \
        --profile $profile
    aws cloudformation wait stack-create-complete \
        --stack-name $name \
        --profile $profile
fi
