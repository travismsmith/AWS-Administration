profile=${1:-default}
name="cloud-config"

echo Stack Name: $name
echo Deleting Stack
aws cloudformation update-termination-protection \
    --no-enable-termination-protection \
    --stack-name $name \
    --profile $profile
aws cloudformation delete-stack \
    --stack-name $name \
    --profile $profile
aws cloudformation wait stack-delete-complete \
    --stack-name $name \
    --profile $profile
