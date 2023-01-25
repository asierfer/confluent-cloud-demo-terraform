# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment" "prod" {
  display_name = "${var.my_prefix}env"

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_kafka_cluster" "basic" {
  display_name = "${var.my_prefix}basic"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluent_environment.prod.id
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_service_account" "sa-cloud" {
  display_name = "${var.my_prefix}sa-1"
  description  = "Service Account for testing"
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "${var.my_prefix}api-key"
  description  = "Kafka API Key that is owned by created service account"
  owner {
    id          = confluent_service_account.sa-cloud.id
    api_version = confluent_service_account.sa-cloud.api_version
    kind        = confluent_service_account.sa-cloud.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.prod.id
    }
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}


resource "confluent_kafka_acl" "describe-basic-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.sa-cloud.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_role_binding" "cluster-rb" {
  principal   = "User:${confluent_service_account.sa-cloud.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = "${confluent_kafka_cluster.basic.rbac_crn}"
}

resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "orders"
  partitions_count   = 3
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_kafka_topic" "account" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "account"
  partitions_count   = 3
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}


resource "confluent_connector" "datagen_source_orders" {
  environment {
    id = confluent_environment.prod.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.my_prefix}DatagenSourceConnector_0"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.orders.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }

/*
  lifecycle {
    prevent_destroy = true
  }
*/
}

//-------- OPTIONAL SFDC Bulk --------------------------------
/*
resource "confluent_connector" "salesforce_source_bulkAPI" {
  environment {
    id = confluent_environment.prod.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "SalesforceBulkApiSource"
    "name"                     = "${var.my_prefix}SalesforceBulkApiSource"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.account.topic_name
    "salesforce.instance"      = var.sfdc_instance
    "salesforce.username"      = var.sfdc_user_name
    "salesforce.password"      = var.sfdc_user_password
    "salesforce.password.token"= var.sfdc_token
    "salesforce.object"        = "ACCOUNT"
    "salesforce.since"         = "1990-01-01"
    "output.data.format"       = "JSON"
    "tasks.max"                = "1"
  }


  lifecycle {
    prevent_destroy = true
  }

}
*/
//-------- END OPTIONAL SFDC Bulk --------------------------------

//Create dedicated cluster and cluster linking
resource "confluent_kafka_cluster" "dedicated" {
  display_name = "${var.my_prefix}dedicated"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  dedicated {
    cku = 1
  }

  environment {
    id = confluent_environment.prod.id
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_api_key" "app-manager-kafka-api-key-prod" {
  display_name = "${var.my_prefix}api-key-dedicated"
  description  = "Kafka API Key that is owned by created service account"
  owner {
    id          = confluent_service_account.sa-cloud.id
    api_version = confluent_service_account.sa-cloud.api_version
    kind        = confluent_service_account.sa-cloud.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.dedicated.id
    api_version = confluent_kafka_cluster.dedicated.api_version
    kind        = confluent_kafka_cluster.dedicated.kind

    environment {
      id = confluent_environment.prod.id
    }
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_role_binding" "cluster-rb2" {
  principal   = "User:${confluent_service_account.sa-cloud.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = "${confluent_kafka_cluster.dedicated.rbac_crn}"
}

//cluster link
resource "confluent_cluster_link" "destination-outbound" {
  link_name = "${var.my_prefix}destination-init-cluster-link"
  source_kafka_cluster {
    id                 = confluent_kafka_cluster.basic.id
    bootstrap_endpoint = confluent_kafka_cluster.basic.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.app-manager-kafka-api-key.id
      secret = confluent_api_key.app-manager-kafka-api-key.secret
    }
  }

  destination_kafka_cluster {
    id            = confluent_kafka_cluster.dedicated.id
    rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-kafka-api-key-prod.id
      secret = confluent_api_key.app-manager-kafka-api-key-prod.secret
    }
  }
  
  depends_on = [
    confluent_role_binding.cluster-rb,
    confluent_role_binding.cluster-rb2
  ]
  //lifecycle {
    //prevent_destroy = true
  //}
}

resource "confluent_kafka_mirror_topic" "mirror-topic" {
  source_kafka_topic {
    topic_name = confluent_kafka_topic.orders.topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.destination-outbound.link_name
  }
  kafka_cluster {
    id            = confluent_kafka_cluster.dedicated.id
    rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-kafka-api-key-prod.id
      secret = confluent_api_key.app-manager-kafka-api-key-prod.secret
    }
  }

  //lifecycle {
    //prevent_destroy = true
  //}
}

//-------- OPTIONAL AWS S3 Connector and S3 Bucket MODULE  --------------------------------
/*
//AWS provider
provider "aws" {
  region = "us-east-2"
}

//Creation of aws bucket
module "s3_bucket" {
  source = "./modules/aws"
}

resource "confluent_connector" "s3_sink" {
  environment {
    id = confluent_environment.prod.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }

  // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_sensitive = {
    "aws.access.key.id"     = var.aws_key
    "aws.secret.access.key" = var.aws_secret
  }

  // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_nonsensitive = {
    "topics"                   = confluent_kafka_topic.orders.topic_name
    "input.data.format"        = "JSON"
    "connector.class"          = "S3_SINK"
    "name"                     = "${var.my_prefix}-S3-SINKConnector-0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.sa-cloud.id
    "s3.bucket.name"           = "${var.my_prefix}test"
    "output.data.format"       = "JSON"
    "time.interval"            = "DAILY"
    "flush.size"               = "1000"
    "tasks.max"                = "1"
  }
  depends_on = [
    module.s3_bucket
  ]
  //lifecycle {
    //prevent_destroy = true
  //}
}
*/
//-------- END OPTIONAL AWS S3 Connector and S3 Bucket MODULE  --------------------------------



