#!/bin/bash

mkdir -pv build
zip -r build/node-example.zip * -x "build/" "build.sh" "common.sh" "deploy.sh" "post-deploy.py" "int-tests.sh"
