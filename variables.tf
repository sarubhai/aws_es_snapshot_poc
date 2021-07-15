# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create 1 Elasticsearch Domain resource

# Tags
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
  default     = "aws-infra"
}

variable "owner" {
  description = "This owner name tag will be included in the owner of the resources."
  default     = "Saurav Mitra"
}


# Elasticsearch Domain
variable "elasticsearch_version" {
  description = "The elasticsearch version."
  default     = "7.9"
}

variable "datanode_instance_type" {
  description = "The Data Node Instance Type."
  default     = "t3.medium.elasticsearch"
}

variable "datanodes_count" {
  description = "The Number of Data Nodes."
  default     = 3
}

variable "ebs_volume_size_datanodes" {
  description = "The EBS Volume Size of Data Nodes in GiB."
  default     = 10
}

variable "ebs_volume_type" {
  description = "The EBS Volume Type. (standard, gp2, or io1)"
  default     = "gp2"
}

variable "iops" {
  description = "The IOPs of Data Nodes"
  default     = 1000
}

variable "masternode_instance_type" {
  description = "The Master Node Instance Type."
  default     = "t3.medium.elasticsearch"
}

variable "masternodes_count" {
  description = "The Number of Master Nodes."
  default     = 3
}

variable "master_user_name" {
  description = "The Master Username of Elasticsearch."
  default     = "elastic"
}

variable "master_user_password" {
  description = "The Master Password Elasticsearch."
}

variable "saml_entity_id" {
  description = "The unique Entity ID of the application in SAML Identity Provider."
}

variable "saml_master_user_name" {
  description = "The SAML Master Username of Elasticsearch."
  default     = "elastic"
}

variable "saml_master_backend_role" {
  description = "The SAML Master Backed Role of Elasticsearch."
}
