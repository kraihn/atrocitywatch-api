#!/bin/bash

my_dir=$(dirname $0)
. "${my_dir}/common.sh"

require_env_var JOB_NAME
require_env_var BUILD_NUMBER

eb_url=$(get_eb_url ${JOB_NAME} ${BUILD_NUMBER})

echo "Testing EB url: ${eb_url}"

response_file=$(mktemp -t /tmp)
response_code=$(curl -o ${response_file} -w '%{http_code}' -s -S ${eb_url})

if [ $? -ne 0 ]; then
	echo "Test ERROR."
	exit 1
elif [ ${response_code} -lt 200 -o ${response_code} -gt 299 ]; then
	echo "Test FAILED with HTTP status code ${response_code}. HTTP response was:"
	cat "${response_file}"
	exit 1
else
	echo "Test PASSED with HTTP status code ${response_code}"
	exit 0
fi

