#!/bin/bash

## Create a new pipeline in the current directory

ORGANIZATION_NAME=
PROJECT_NAME=
$_project_name

## Create pipeline directory
# az pipelines folder create --path development --organization https://dev.azure.com/kagemaru213 --project "${PROJECT_NAME}"


## Create pipeline d

create_pipeline() {
  local -r _organization_name="$1"
  local -r _project_name="$2"
  local -r _organization_url="https://dev.azure.com/${_organization_name}"
  local -r _variable_group_name="test_variable_group"
  local -r _pipeline_name="SamplePipeline"
  local -r _pipeline_description="This is a sample pipeline created by a script."
  local -r _repository_name="sample-webapp"
  local -r _yaml_file_path="build.yml"

  # Create a environment
  az devops invoke --area distributedtask --resource environments --route-parameters "project=${_project_name}" --org "${_organization_url}" --http-method POST --in-file "environment_body.json" --api-version "6.0-preview"

  # Create a variable group
  az pipelines variable-group create --name "${_variable_group_name}" -p "${_project_name}" --org "${_organization_url}" --authorize --variables var1="val1" var2="val2"

  az pipelines folder create --org "${_organization_url}" -p "${_project_name}" --path development

  # Create a pipeline
  # (※)–skip-first-run は, Azure DevOps にパイプラインをすぐに実行しないようにする。
  az pipelines create -p "${_project_name}" --org "${_organization_url}" --name "${_pipeline_name}" --description "${_pipeline_description}" --folder-path "development" --repository "${_repository_name}" --repository-type tfsgit --branch master --skip-first-run --yml-path "${_yaml_file_path}" #[--service-connection SERVICE_CONNECTION]
  az pipelines variable create -p "${_project_name}" --org "${_organization_url}" --pipeline-name "${_pipeline_name}" --name myVar --value "some value" --allow-override true
}

create_pipeline "${ORGANIZATION_NAME}" "${PROJECT_NAME}"
