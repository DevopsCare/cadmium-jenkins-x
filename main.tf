/*
 * Copyright (C) 2019 Risk Focus, Inc. - All Rights Reserved
 * You may use, distribute and modify this code under the
 * terms of the Apache License Version 2.0.
 * http://www.apache.org/licenses
 */

locals {
  git_provider_url = {
    "github"         = "https://github.com"
    "bitbucketcloud" = "https://bitbucket.org"
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_filename
}

resource "null_resource" "jx" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    jx = var.jx_platform_version
  }

  provisioner "local-exec" {
    command = "jx install --version=${var.jx_platform_version} --batch-mode=true --provider=eks --no-default-environments=true --skip-ingress=true  --default-admin-password=${var.default_admin_password} --domain=${var.domain} --environment-git-owner=${var.environment_git_owner} --git-public=false --git-provider-url=${local.git_provider_url[var.git_provider]} --git-provider-kind=${var.git_provider} --git-username=${var.git_username} --git-api-token=${var.git_api_token}"

    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
}

resource "null_resource" "annotate" {
  triggers = {
    jx = null_resource.jx.id
  }

  provisioner "local-exec" {
    command = "kubectl annotate -n jx ingress -l provider=fabric8 certmanager.k8s.io/issuer-"

    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
}

// See https://jenkinsci.github.io/kubernetes-credentials-provider-plugin/
resource "kubernetes_secret" "bitbucket-token" {
  count = var.git_provider == "bitbucketcloud" ? 1 : 0
  metadata {
    name      = "bitbucket-token"
    namespace = "jx"

    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" = "usernamePassword"
      "jenkins.io/kind"             = "git"
    }

    annotations = {
      # description - can not be a label as spaces are not allowed
      "jenkins.io/credentials-description" = "Bitbucket Organization CI Token"
      "jenkins.io/url"                     = local.git_provider_url[var.git_provider]
    }
  }

  data = {
    username = var.git_username
    password = var.git_api_token
  }

  depends_on = [
    null_resource.jx,
  ]
}

resource "kubernetes_secret" "github-usernamePassword" {
  count = var.git_provider == "github" ? 1 : 0

  metadata {
    name      = "github-username-password"
    namespace = "jx"

    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" = "usernamePassword"
      "jenkins.io/kind"             = "git"
    }

    annotations = {
      # description - can not be a label as spaces are not allowed
      "jenkins.io/credentials-description" = "GitHub Organization CI Username/Pass"
      "jenkins.io/url"                     = local.git_provider_url[var.git_provider]
    }
  }

  data = {
    username = var.git_username
    password = var.git_api_token
  }

  depends_on = [
    null_resource.jx
  ]
}

resource "kubernetes_secret" "cadmium-usernamePassword" {
  count = var.git_provider == "github" ? 1 : 0

  metadata {
    name      = "cadmium"
    namespace = "jx"

    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" = "usernamePassword"
    }

    annotations = {
      # description - can not be a label as spaces are not allowed
      "jenkins.io/credentials-description" = "Cadmium repo compatibility"
      "jenkins.io/url"                     = local.git_provider_url[var.git_provider]
    }
  }

  data = {
    username = var.git_username
    password = var.git_api_token
  }

  depends_on = [
    null_resource.jx,
  ]
}

resource "kubernetes_secret" "github-token" {
  count      = var.git_provider == "github" ? 1 : 0
  depends_on = [null_resource.jx]

  metadata {
    name      = "github-token"
    namespace = "jx"

    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" = "secretText"
    }

    annotations = {
      # description - can not be a label as spaces are not allowed
      "jenkins.io/credentials-description" = "GitHub Organization CI Token"
      "jenkins.io/url"                     = local.git_provider_url[var.git_provider]
    }
  }

  data = {
    text = var.git_api_token
  }
}
