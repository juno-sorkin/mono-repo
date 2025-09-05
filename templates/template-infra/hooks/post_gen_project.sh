#!/bin/bash

set -e

# must run concurrent work with command ->
# cookiecutter templates/template-infra -o infra-packages/aws/metaflow_batch
PANTS_CONCURRENT=True pants :: tailor
