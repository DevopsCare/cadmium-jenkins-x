/*
 * Copyright (C) 2019 Risk Focus, Inc. - All Rights Reserved
 * You may use, distribute and modify this code under the
 * terms of the Apache License Version 2.0.
 * http://www.apache.org/licenses
 */

variable "default_admin_password" {
  type = string
}

variable "jx_platform_version" {
  type    = string
  default = "2.0.1800"
}

variable "domain" {
  type = string
}

variable "environment_git_owner" {
  type = string
}

variable "git_provider" {
  type    = string
  default = "github"
}

variable "git_username" {
  type = string
}

variable "git_api_token" {
  type = string
}

variable "kubeconfig_filename" {
}
