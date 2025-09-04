#!/bin/bash

set -e

# must run concurrent work work with command ->
# pants run //tools:cookiecutter -- emplates/template-infra -o infra-packages/aws/metaflow:batch
PANTS_CONCURRENT=True pants :: tailor
