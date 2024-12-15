resource "aws_dms_replication_task" "task" {
  replication_task_id      = var.replication_id
  migration_type           = var.migration_type
  replication_instance_arn = var.instance_arn
  source_endpoint_arn      = var.source_arn
  table_mappings           = var.mappings_rules
  target_endpoint_arn      = var.target_arn

  replication_task_settings = <<EOF
    {
        "Logging": {
            "EnableLogging": true,
            "EnableLogContext": false,
            "LogComponents": [
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "TRANSFORMATION"
                },
                {
                    "Severity": "LOGGER_SEVERITY_ERROR",
                    "Id": "SOURCE_UNLOAD"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "IO"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEBUG",
                    "Id": "TARGET_LOAD"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "PERFORMANCE"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEBUG",
                    "Id": "SOURCE_CAPTURE"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "SORTER"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "REST_SERVER"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "VALIDATOR_EXT"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEBUG",
                    "Id": "TARGET_APPLY"
                },
                {
                    "Severity": "LOGGER_SEVERITY_ERROR",
                    "Id": "TASK_MANAGER"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "TABLES_MANAGER"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "METADATA_MANAGER"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "FILE_FACTORY"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "COMMON"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "ADDONS"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "DATA_STRUCTURE"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "COMMUNICATION"
                },
                {
                    "Severity": "LOGGER_SEVERITY_DEFAULT",
                    "Id": "FILE_TRANSFER"
                }
            ]
        },
        "TargetMetadata": {
            "LobMaxSize": 32632
        },
        "StreamBufferSettings": {
            "StreamBufferCount": 5,
            "CtrlStreamBufferSizeInMB": 8,
            "StreamBufferSizeInMB": 32
        },
        "ChangeProcessingTuning": {
            "StatementCacheSize": 50,
            "CommitTimeout": 1,
            "BatchApplyPreserveTransaction": true,
            "BatchApplyTimeoutMin": 1,
            "BatchSplitSize": 0,
            "BatchApplyTimeoutMax": 30,
            "MinTransactionSize": 1000,
            "MemoryKeepTime": 120,
            "BatchApplyMemoryLimit": 500,
            "MemoryLimitTotal": 4096
        }
    }
    EOF

  tags = {
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }
}
