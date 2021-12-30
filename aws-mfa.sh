#!/bin/bash

[ -z $1 ] && echo "Please enter your MFA code" && exit 1

# mfa arn
serial=arn:aws:iam::999999999999:mfa/username

# IAM cli profile 
iam_profile=profile_name

# profile with mfa creds
mfa_profile=default

output=$(aws sts get-session-token \
                --query 'Credentials.[SecretAccessKey,AccessKeyId,SessionToken]' \
                --output text \
		--profile $iam_profile \
                --serial-number $serial \
		--duration-seconds 129600 \
                --token-code $1 \
        ) || exit 1
aws_secret_access_key=$(echo $output | cut -f1 -d ' ')
aws_access_key_id=$(echo $output | cut -f2 -d ' ')
aws_session_token=$(echo $output | cut -f3 -d ' ')

aws configure set profile.$mfa_profile.aws_access_key_id $aws_access_key_id
aws configure set profile.$mfa_profile.aws_secret_access_key $aws_secret_access_key
aws configure set profile.$mfa_profile.aws_session_token $aws_session_token
