#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <stage> <region>"
  exit 1
fi

stage=$1
region=$2

echo "getting_base_url_api.sh --> Input 1 'stage' value: $stage"
echo "getting_base_url_api.sh --> Input 2 'region' value: $region"

outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws --region $region | jq '.Stacks[0].Outputs')

extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

BASE_URL_API=$(extract_value "BaseUrlApi")

echo $BASE_URL_API > my_base_url_api.tmp
