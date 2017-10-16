
#!/bin/bash

function execute {
    local base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    . "${base_dir}/../../config.sh"

    local stack_name="${PROJECT_PREFIX}-state-machine"
    local template="${base_dir}/state_machine_template.yaml"
    local output_file="/tmp/state_machine_template-output.yaml"
    local state_machine_input_file="${base_dir}/state_machine_input.json"

    echo "[== Provisioning Step Functions state machine resources ==]"
    echo "- stack_name: $stack_name"
    echo "- STATE_MACHINE_S3_BUCKET: $STATE_MACHINE_S3_BUCKET"
    echo "- template: $template"
    echo "- output_file: $output_file"

    create_bucket_if_it_doesnt_exist $STATE_MACHINE_S3_BUCKET $AWS_REGION
    echo "Copying state machine input parameters file \"state_machine_input_file\" to S3 bucket: $STATE_MACHINE_S3_BUCKET"
    aws s3 cp "$state_machine_input_file" "s3://$STATE_MACHINE_S3_BUCKET"

    aws cloudformation package --template-file "$template" --s3-bucket "$STATE_MACHINE_S3_BUCKET" --output-template-file "$output_file"
    aws cloudformation deploy --template-file "$output_file" --stack-name "$stack_name" --capabilities CAPABILITY_IAM

    export STATE_MACHINE_STACK_NAME=$stack_name
}

execute