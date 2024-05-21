/*
This file provisions the GCP infrastructure required to trigger a Cloud Function
in response to a Cloud Logging log event. Reference the module documentation for
a description of the architecture employed.
*/


# Create a GCS bucket in which to store the Cloud Functions' source code
resource "google_storage_bucket" "cloud_function_src_code_bucket" {
  project                     = var.project_id
  name                        = "wcm-test-51424"
  location                    = var.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = var.labels
}

# Create a zip file containing all the source code files present in the './src' directory
data "archive_file" "zipped_src_code_files" {
  type        = "zip"
  source_dir  = "./http_v2_cloud_function/src"
  output_path = "/tmp/function.zip"
}

/*
Create a GCS object inside the Cloud Function source code storage bucket comprised of
the zipped source code file
*/
resource "google_storage_bucket_object" "zipped_src_code_object" {
  source       = data.archive_file.zipped_src_code_files.output_path
  content_type = "application/zip"

  /*
  Append the MD5 checksum of the source code files' contents to the object name
  to force a name change to occur upon any change to the source code files
  (note the object name is referenced in the Cloud Function definition below).
  */
  name         = "src-${data.archive_file.zipped_src_code_files.output_md5}.zip"
  bucket       = google_storage_bucket.cloud_function_src_code_bucket.name
}

# Create a service account used by the Cloud Function to authenticate to GCP
resource "google_service_account" "vdi_create_fn_svc_acct" {
  project      = var.project_id
  account_id   = "python-http-function"
  display_name = "The service account for the python http function"
}

resource "google_secret_manager_secret" "frame_key_secret" {
  project   = var.project_id
  secret_id = "frame-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project = var.project_id
  secret_id = google_secret_manager_secret.frame_key_secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.vdi_create_fn_svc_acct.email}",
  ]
}

/*
Create a Cloud Function which is triggered in response to log events
being published to the log sink destination Pub/Sub topic.
*/
resource "google_cloudfunctions2_function" "function" {
  project = var.project_id
  name = var.cloud_function_name
  location = var.region
  description = "A python based http v2 cloud function"

  build_config {
    runtime = "python312"
    entry_point = var.entrypoint  # Set the entry point
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_src_code_bucket.name
        object = google_storage_bucket_object.zipped_src_code_object.name
      }
    }
  }

  service_config {
    environment_variables = {
      PROJECT_ID = var.project_id
    }
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
    service_account_email = google_service_account.vdi_create_fn_svc_acct.email
  }
}


