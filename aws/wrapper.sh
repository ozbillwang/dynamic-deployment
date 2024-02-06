#!/usr/bin/env bash

# Before running this script, make sure you have permission on the target aws account

# Get the current account alias
account_alias=$(aws iam list-account-aliases --output text --query 'AccountAliases[0]')

# Check if the account alias is "None" or empty
if [ -z "$account_alias" ] || [ "$account_alias" == "None" ]; then
    echo "AWS account does not have an account alias. Exiting."
    exit 1
else
    echo "AWS account alias: $account_alias"
fi

# Check if there are two parameters
if [ -z "$1" ]; then
  echo "Usage: $0 <servierName> <payload>"
  echo "Sample: $0 plan budget dev '{"key1": "value1", "key2": "value2", "key3": "value3"}' "
  exit 1
fi

action=$1
serviceName=$2
env=$3
payload="${4:-""}"

while IFS=: read -r key value; do
  export "TF_VAR_$key=$value"
  echo "Variable: TF_VAR_$key, Value: $value"
done < <(jq -r 'to_entries[] | "\(.key):\(.value)"' <<< "$payload")

accountName=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)
accountId=$(aws sts get-caller-identity --query 'Account' --output text)

echo $accountId
echo $accountName

rm -rf ./${accountName}

# Run the boilerplate command
boilerplate \
  --template-url ./template_${serviceName} \
  --output-folder "${accountName}" \
  --non-interactive \
  --var accountName="${accountName}" \
  --var accountId=\'${accountId}\'
  --var env=\'${env}\'

pushd ${accountName}
case "$action" in
  "apply")
    terragrunt run-all apply
    ;;
  "plan")
    terragrunt run-all plan  --terragrunt-non-interactive -out='planfile'
    ;;
  *)
    echo "Invalid action. Supported actions: apply, plan"
    exit 1
    ;;
esac
popd

echo "apply the change, after confirmed"
echo pushd ${accountName}/ap-southeast-2/env/${serviceName}/
echo terragrunt apply "planfile"
echo popd
