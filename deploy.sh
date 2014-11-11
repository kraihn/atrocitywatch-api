#!/bin/bash

my_dir=$(dirname $0)
. "${my_dir}/common.sh"

require_env_var AWS_REGION
require_env_var JENKINS_S3_BUCKET
require_env_var BEANSTALK_APPLICATION
require_env_var JOB_NAME
require_env_var BUILD_NUMBER

ENV_NAME="${JOB_NAME}-ci"
SOLUTION_STACK_NAME="64bit Amazon Linux 2014.09 v1.0.9 running Node.js"
S3_KEY_NAME="${JOB_NAME}-b${BUILD_NUMBER}.zip"
DEPLOY_FILE="build/${JOB_NAME}.zip"
EB_DEPLOY_TIMEOUT_SECS=600

macMetaDataURL="http://169.254.169.254/latest/meta-data/network/interfaces/macs/"
macAddress="$(curl ${macMetaDataURL})"
vpcAddress="${macMetaDataURL}${macAddress}vpc-id"
VPC_ID="$(curl ${vpcAddress})"


bsPrivateSubnetA="$(aws ec2 describe-subnets --region ${AWS_REGION} --filter Name=vpc-id,Values=${VPC_ID} Name=tag-value,Values=BeanstalkPrivateSubnetA | grep SubnetId | cut -c 26-40)"
bsPrivateSubnetB="$(aws ec2 describe-subnets --region ${AWS_REGION} --filter Name=vpc-id,Values=${VPC_ID} Name=tag-value,Values=BeanstalkPrivateSubnetB | grep SubnetId | cut -c 26-40)"
bsPublicSubnetA="$(aws ec2 describe-subnets --region ${AWS_REGION} --filter Name=vpc-id,Values=${VPC_ID} Name=tag-value,Values=BeanstalkPublicSubnetA | grep SubnetId | cut -c 26-40)"
bsPublicSubnetB="$(aws ec2 describe-subnets --region ${AWS_REGION} --filter Name=vpc-id,Values=${VPC_ID} Name=tag-value,Values=BeanstalkPublicSubnetB | grep SubnetId | cut -c 26-40)"


deploy_eb_app \
	"${AWS_REGION}" \
	"${BEANSTALK_APPLICATION}" \
	"${BUILD_NUMBER}" \
	"${ENV_NAME}" \
	"${SOLUTION_STACK_NAME}" \
	"${JENKINS_S3_BUCKET}" \
	"${S3_KEY_NAME}" \
	"${DEPLOY_FILE}" \
	"${VPC_ID}" \
	"${bsPrivateSubnetA}" \
	"${bsPrivateSubnetB}" \
	"${bsPublicSubnetA}" \
	"${bsPublicSubnetB}"

# wait_for_eb "${BEANSTALK_APPLICATION}" "${BUILD_NUMBER}"

exit $?

