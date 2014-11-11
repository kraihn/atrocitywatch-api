#!/bin/bash

#
# Common tasks for working with Elastic Beanstalk.
#

EB_DEPLOY_TIMEOUT_SECS=600

function require_env_var {
	var_name="$1"
	eval var_value=\$$var_name

	if [ -z "${var_value}" ]; then
		echo "Required environment variable $var_name is not set. Exiting."
		exit 1
	fi

	echo "Using ${var_name}=${var_value}"
}

function do_task {
	local exit_on_failure
	local rc

	case "$1" in
		continue_on_failure)
			exit_on_failure=false
			;;
		exit_on_failure)
			exit_on_failure=true
			;;
		*)
			echo "Internal error: do_task() expects first arg to be 'continue_on_failure' or 'exit_on_failure'. Exiting."
			exit 1
			;;
	esac

	shift

	echo
	echo "Executing: [$@]"
	echo

	"$@"

	rc=$?
	echo

	if [ $rc -eq 0 ]; then
		echo "Command completed successfully."
	elif [ "${exit_on_failure}" == "true" ]; then
		echo "Command failed. Exiting."
		exit 1
	else
		echo "Command failed. Continuing anyway."
	fi

	return $rc
}

function deploy_eb_app {
	local eb_region="$1"
	local eb_app_name="$2"
	local eb_app_version="$3"
	local eb_env_name="$4"
	local eb_solution_stack="$5"
	local eb_s3_bucket="$6"
	local eb_s3_key="$7"
	local eb_local_file="$8"
	local vpc_id="$9"
	local bsPrivateSubnetA="${10}"
	local bsPrivateSubnetB="${11}"
	local bsPublicSubnetA="${12}"
	local bsPublicSubnetB="${13}"

	echo "PAUL"
	echo ${bsPrivateSubnetA}

	do_task exit_on_failure \
		aws s3api put-object \
		--region "${eb_region}" \
		--bucket "${eb_s3_bucket}" \
		--key "${eb_s3_key}" \
		--body "${eb_local_file}"

	do_task continue_on_failure \
		aws elasticbeanstalk create-application \
		--region "${eb_region}" \
		--application-name "${eb_app_name}" \
		--description "Application ${eb_app_name}"

	do_task exit_on_failure \
		aws elasticbeanstalk create-application-version \
		--region "${eb_region}" \
		--application-name "${eb_app_name}" \
		--version-label "${eb_app_version}" \
		--description "Application ${eb_app_name} version ${eb_app_version}" \
		--source-bundle "S3Bucket=${eb_s3_bucket},S3Key=${eb_s3_key}" 
		
	do_task continue_on_failure \
		aws elasticbeanstalk create-environment \
		--region "${eb_region}" \
		--application-name "${eb_app_name}" \
		--environment-name "${eb_env_name}" \
		--version-label "${eb_app_version}" \
		--solution-stack-name "${eb_solution_stack}" \
		--option-settings \
			Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value="t2.medium" \
			Namespace=aws:ec2:vpc,OptionName=VPCId,Value="${vpc_id}" \
			Namespace=aws:ec2:vpc,OptionName=Subnets,Value="${bsPrivateSubnetA}" \
			Namespace=aws:ec2:vpc,OptionName=Subnets,Value="${bsPrivateSubnetB}" \
			Namespace=aws:ec2:vpc,OptionName=ELBSubnets,Value="${bsPublicSubnetA}" \
			Namespace=aws:ec2:vpc,OptionName=ELBSubnets,Value="${bsPublicSubnetB}" \
		--description "Environment ${eb_env_name} for application ${eb_app_name} version ${eb_app_version}"		

	if [ $? -eq 0 ]; then
		echo "Environment created successfully."
	else
		echo "Environment already exists. Updating."

		do_task exit_on_failure \
			aws elasticbeanstalk update-environment \
			--region "${eb_region}" \
			--environment-name "${eb_env_name}" \
			--version-label "${eb_app_version}" \
			--option-settings \
				Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value="t2.medium" \
				Namespace=aws:ec2:vpc,OptionName=VPCId,Value="${vpc_id}" \
				Namespace=aws:ec2:vpc,OptionName=Subnets,Value="${bsPrivateSubnetA}" \
				Namespace=aws:ec2:vpc,OptionName=Subnets,Value="${bsPrivateSubnetB}" \
				Namespace=aws:ec2:vpc,OptionName=ELBSubnets,Value="${bsPublicSubnetA}" \
				Namespace=aws:ec2:vpc,OptionName=ELBSubnets,Value="${bsPublicSubnetB}" \
			--description "Environment ${eb_env_name} for application ${eb_app_name} version ${eb_app_version}"

		echo "Environment updated successfully."
	fi
}

function wait_for_eb {
	local app_name="$1"
	local version_label="$2"

	local start_time_secs
	local timeout_time_secs
	local current_time_secs
	local deploy_result

	start_time_secs=$(date '+%s')
	current_time_secs=$(date '+%s')
	timeout_time_secs=$(( ${start_time_secs} + ${EB_DEPLOY_TIMEOUT_SECS} ))
	elapsed_time_secs=$(( ${current_time_secs} - ${start_time_secs} ))

	echo -n "Waiting for environment Status=Ready"
	while [ -z "${deploy_result}" ]; do
		case $(aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label} | jq -r '.Environments[0].Status') in
			Launching|Updating)
				echo -n "."
				;;
			Ready)
				echo "Success."
				break
				;;
			*)
				echo
				echo "Deployment failed in ${elapsed_time_secs} seconds."
				do_task continue_on_failure aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label}
				return 1
				;;
		esac

		current_time_secs=$(date '+%s')
		elapsed_time_secs=$(( ${current_time_secs} - ${start_time_secs} ))

		if [ ${current_time_secs} -gt ${timeout_time_secs} ]; then
			echo
			echo "Timed out waiting for Elastic Beanstalk deployment after ${EB_DEPLOY_TIMEOUT_SECS} seconds."
			do_task continue_on_failure aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label}
			return 1
		else
			sleep 5
		fi
	done

	echo -n "Waiting for environment Health=Green"
	while [ -z "${deploy_result}" ]; do
		case $(aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label} | jq -r '.Environments[0].Health') in
			Green)
				echo "Success."
				break
				;;
			*)
				echo -n "."
				;;
		esac

		current_time_secs=$(date '+%s')
		elapsed_time_secs=$(( ${current_time_secs} - ${start_time_secs} ))

		if [ ${current_time_secs} -gt ${timeout_time_secs} ]; then
			echo
			echo "Deployment failed in ${elapsed_time_secs} seconds."
			do_task continue_on_failure aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label}
			return 1
		else
			sleep 5
		fi
	done

	echo "Deployment succeeded in ${elapsed_time_secs} seconds."
	#do_task continue_on_failure aws elasticbeanstalk describe-environments --application-name ${app_name} --version-label ${version_label}
	return 0
}

function get_eb_url {
	local eb_app_name="$1"
	local eb_app_version="$2"

	aws elasticbeanstalk describe-environments \
		--application-name "${eb_app_name}" \
		--version-label "${eb_app_version}" | jq -r '.Environments[0].CNAME'
}

