#!/usr/bin/python

################################################################################
#
# This script is intended to be executed after an Elastic Beanstalk version
# is deployed by Jenkins. It collects information about the newly running
# Beanstalk stack, and puts that information into a DynamoDB table. The
# project status page can then query this table while generating the page.
# Without the information in the Dynamo table we would need to do multiple
# AWS API calls during each page load.
#
################################################################################

import os
from pprint import pprint
import sys

import boto.beanstalk
import boto.cloudformation
from boto.dynamodb2.table import Table
from boto.dynamodb2.table import Item

def get_required_env_var(key):
	value=os.environ.get(key)

	if value is None:
		print "Fatal: Required environment variable {0} is not set. Exiting.".format(key)
		sys.exit(1)

	return value

def get_outputs_for_cfn_stack(cfn, stack_id):
	stacks = cfn.describe_stacks(stack_id)

	if len(stacks) < 1:
		print "Fatal: CloudFormation stack {0} does not exist. Exiting.".format(stack_id)
		sys.exit(1)
	elif len (stacks) > 1:
		print "Fatal: Multiple CloudFormation stacks found for stack id {0}. Exiting.".format(stack_id)
		sys.exit(1)

	stack = stacks[0]
	result = { }

	for output in stacks[0].outputs:
		result[output.key] = output.value

	return result

def get_beanstalk_env(beanstalk, application_name, version_label):
	response = beanstalk.describe_environments(
		application_name=application_name,
		version_label=version_label)

	beanstalk_envs = response['DescribeEnvironmentsResponse']['DescribeEnvironmentsResult']['Environments']

	if len(beanstalk_envs) < 1:
		print "Fatal: Beanstalk app {0} version {1} is not deployed. Exiting.".format(job_name, build_number)
		sys.exit(1)
	elif len(beanstalk_envs) > 1:
		print "Fatal: Multiple beanstalk deployments found for app {0} version {1}. Exiting.".format(job_name, build_number)
		sys.exit(1)

	return beanstalk_envs[0]

print "Running post-deploy script..."

cfn_stack_id=get_required_env_var('CFN_STACK_ID')
aws_region=get_required_env_var('AWS_REGION')
dynamo_table_name=get_required_env_var('JENKINS_DYNAMODB_TABLE')
job_name=get_required_env_var('JOB_NAME')
build_number=get_required_env_var('BUILD_NUMBER')

# Gather CloudFormation info
cfn = boto.cloudformation.connect_to_region(aws_region)
outputs = get_outputs_for_cfn_stack(cfn, cfn_stack_id)
git_url = "git@{0}:{1}".format(outputs['GitServerPublicIP'], job_name)
jenkins_url = "{0}/job/{1}".format(outputs['JenkinsURL'], job_name)

# Gather Beanstalk info
beanstalk = boto.beanstalk.connect_to_region(aws_region)
beanstalk_env = get_beanstalk_env(beanstalk, job_name, build_number)
application_desc = beanstalk_env['Description']
beanstalk_url = "http://{0}".format(beanstalk_env['EndpointURL'])

# Write info to DynamoDB table
data = {
	'application_name' : job_name,
	'application_desc' : application_desc,
	'beanstalk_url' : beanstalk_url,
	'git_url' : git_url,
	'jenkins_url' : jenkins_url
}

print "Writing data to DynamoDB table {0}:".format(dynamo_table_name)
pprint(data)

projects_table = Table(dynamo_table_name)
Item(projects_table, data).save(overwrite=True)

print "Post-deploy completed successfully."
sys.exit(0)

