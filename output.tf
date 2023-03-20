output "internal_ip_address_vm_1" {
  value = module.morsh_instance_ya_1.internal_ip_address_morsh_server
}

output "external_ip_address_vm_1" {
  value = module.morsh_instance_ya_1.external_ip_address_morsh_server
}

output "hostname_vm_1" {
  value = module.morsh_instance_ya_1.hostname_morsh_server
}


output "ssh_key_server_pub" {
  value     = data.ansiblevault_path.ssh_server_pub.value
  sensitive = true
}

output "jenkins_agent_2_secret" {
  value     = data.ansiblevault_path.jenkins_agent_2_secret.value
  sensitive = true
}

output "jenkins_agent_1_secret" {
  value     = data.ansiblevault_path.jenkins_agent_1_secret.value
  sensitive = true
}

output "jenkins_archive_password" {
  value     = data.ansiblevault_path.jenkins_archive_password.value
  sensitive = true
}
