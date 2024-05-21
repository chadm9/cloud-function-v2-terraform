<!-- BEGIN_TF_DOCS -->
# Cloud Logging Triggered Cloud Function

## Overview
This module provisions a Cloud Function which is triggered in response
to specific Cloud Logging log events.  In this architecture, a Cloud
Logging log sink is created which forwards log events matching a
supplied log query filter to a destination Pub/Sub topic. The destination
topic then tiggers a Cloud Function, passing the log event to the function
as input.  This pattern is useful for automating the handling / response
to specific events which occur in GCP.
![cldfn-arch-diagram](cldfn.png?raw=true)

## Requirements

The core requirements for this module are a functioning Cloud Logging log query
which isolates the specific event(s) desired to trigger the Cloud Function, and the
Cloud Function source code.  The source code file(s) should be placed in the
src directory, and are automatically zipped and uploaded to Cloud Storage (where they
can be read by the Cloud Function) on deployment.

## Example

An example of module usage which triggers a Node.js function in response
to a specific user provisioning a Compute Engine VM within a specific GCP
project is presented below.

Module Declaration:
```
module "vdi_vm_network_tagging_resources" {
  source                         = "./modules/log-event-cloud-function-trigger/"

  project_id                     = var.project_id
  region                         = var.region
  cloud_function_name            = var.cloud_function_name
  log_sink_filter                = var.log_sink_filter
  function_runtime               = var.function_runtime
  function_entrypoint            = var.function_entrypoint
  function_max_instances         = var.function_max_instances
  function_environment_variables = var.function_environment_variables
}
```

Variable (tfvars) declaration:
```
project_id             = "pid-gogggnad-cvdi-frame-poa"
region                 = "us-east1"
cloud_function_name    = "tag-vdi-vms"
log_sink_filter        = "protoPayload.authenticationInfo.principalEmail=\"chad.mckee@globalpay.com\" AND protoPayload.request.@type=\"type.googleapis.com/compute.instances.insert\" AND resource.labels.project_id=\"pid-gogggnad-cvdi-frame-poa\""
function_runtime       = "nodejs16"
function_entrypoint    = "processLogEntry"
function_max_instances = 2
function_environment_variables = {
  GCP_PROJECT_ID = "pid-gogggnad-cvdi-frame-poa"
  VDI_VM_NETWORK_TAG = "cvdi-vdi-ins-devqa"
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudfunctions_function.cloud_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_logging_project_sink.project_log_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_pubsub_topic.log_sink_destination_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.pubsub_destination_topic_publisher_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.vdi_create_fn_svc_acct](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.cloud_function_src_code_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.zipped_src_code_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [archive_file.zipped_src_code_files](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_function_name"></a> [cloud\_function\_name](#input\_cloud\_function\_name) | The name of the module's Cloud Function | `string` | n/a | yes |
| <a name="input_function_entrypoint"></a> [function\_entrypoint](#input\_function\_entrypoint) | The method name of entrypoint to the Cloud Function | `string` | n/a | yes |
| <a name="input_function_environment_variables"></a> [function\_environment\_variables](#input\_function\_environment\_variables) | The environment variables to set during function execution. | `map(string)` | `null` | no |
| <a name="input_function_max_instances"></a> [function\_max\_instances](#input\_function\_max\_instances) | The maximum number of function instances that can be concurrently | `number` | `256` | no |
| <a name="input_function_max_memory"></a> [function\_max\_memory](#input\_function\_max\_memory) | The maximum memory available to the function (in mb) | `number` | `256` | no |
| <a name="input_function_runtime"></a> [function\_runtime](#input\_function\_runtime) | The runtime environment (i.e., language and language version) of the Cloud Function (see: https://cloud.google.com/functions/docs/concepts/execution-environment#runtimes) | `string` | n/a | yes |
| <a name="input_function_timeout"></a> [function\_timeout](#input\_function\_timeout) | The maximum number of seconds the function is allowed to run (cannot be larger than 540) | `number` | `60` | no |
| <a name="input_function_vpc_connector"></a> [function\_vpc\_connector](#input\_function\_vpc\_connector) | The fully qualified URI to the Serverless VPC Network Connector to connect the Cloud Function to | `string` | `null` | no |
| <a name="input_function_vpc_connector_egress"></a> [function\_vpc\_connector\_egress](#input\_function\_vpc\_connector\_egress) | Which of the function's network traffic should be routed through the vpc connector | `string` | `"ALL_TRAFFIC"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to attache to module resources | `map(string)` | `null` | no |
| <a name="input_log_sink_filter"></a> [log\_sink\_filter](#input\_log\_sink\_filter) | The Cloud Logging query used to filter log entries | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID in which the module resources will be created | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region in which the module resources will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_function_name"></a> [cloud\_function\_name](#output\_cloud\_function\_name) | Name of the Cloud Function |
| <a name="output_cloud_function_src_code_buket"></a> [cloud\_function\_src\_code\_buket](#output\_cloud\_function\_src\_code\_buket) | Name of the GCS bucket in which the Cloud Function's source code is housed |
| <a name="output_log_sink_name"></a> [log\_sink\_name](#output\_log\_sink\_name) | Name of the log sink |
| <a name="output_pubsub_destination_topic_name"></a> [pubsub\_destination\_topic\_name](#output\_pubsub\_destination\_topic\_name) | Name of the Pub/Sub destination topic |
<!-- END_TF_DOCS -->