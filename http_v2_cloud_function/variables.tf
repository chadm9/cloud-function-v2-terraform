
variable "project_id" {
  type        = string
  description = "The GCP project ID in which the module resources will be created"
}

variable "region" {
  description = "The GCP region in which the module resources will be created"
  type        = string
  default     = "us-east1"
}

variable "labels" {
  type        = map(string)
  default     = null
  description = "Labels to attache to module resources"
}

variable "cloud_function_name" {
  description = "The name of the module's Cloud Function"
  type        = string
  default     = "v2-function"
}

variable "function_runtime" {
  description = "The runtime environment (i.e., language and language version) of the Cloud Function (see: https://cloud.google.com/functions/docs/concepts/execution-environment#runtimes)"
  type        = string
  default     = "python312"
}

variable "entrypoint" {
  description = "The method name of entrypoint to the Cloud Function"
  type        = string
  default     = "hello"
}

variable "function_environment_variables" {
  type        = map(string)
  default     = null
  description = "The environment variables to set during function execution."
}
