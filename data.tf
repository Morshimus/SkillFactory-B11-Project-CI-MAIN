data "ansiblevault_path" "ssh_server_pub" {
  path = "${path.module}/secrets.yml"
  key  = "adm_pub_key"
}

data "ansiblevault_path" "jenkins_agent_1_secret" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_agent_1_secret"
}

data "ansiblevault_path" "jenkins_agent_2_secret" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_agent_2_secret"
}

data "ansiblevault_path" "jenkins_archive_password" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_archive_password"
}