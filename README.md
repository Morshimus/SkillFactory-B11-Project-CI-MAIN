# SkillFactory-B9-JFrog-Artifactory-MAIN

## [Roles](https://github.com/Morshimus/SkillFactory-B9-JFrog-Artifactory-Roles)





## Задание


```groovy
pipeline {
    agent {
       node{
          label 'agent-primary'
        }    
    }
    stages {
        stage('Preparation') { // for display purposes
            steps {
                git branch: 'main', url:'https://github.com/Morshimus/SkillFactory-B11-Project-CI-APP.git'
                sh 'apk update && apk add ansible curl'
                sh 'cd /tmp && ansible-playbook provision.yaml'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t morsh92/skillfactory-web-pg:latest -t morsh92/skillfactory-web-pg:2.1 .' 
            }
        }
        stage('Test'){
            steps {
                sh 'docker rm django-tst -f'
                sh 'docker run --rm --name django-tst -v /tmp/django.conf:/app/django.conf:ro -p 8000:8000 -d morsh92/skillfactory-web-pg:latest'
                sh 'sleep 30 && wget http://localhost:8000/admin && rm admin'
                sh 'docker rm django-tst -f'
            }    
        }
        stage('Release') {
            steps {
            withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'dockerpwd', usernameVariable: 'dockerusr')]) {
                    sh "docker login -u ${dockerusr} -p ${dockerpwd}"
                    sh "docker push morsh92/skillfactory-web-pg:latest"
                    sh "docker push morsh92/skillfactory-web-pg:2.1"
                    sh "docker logout && rm /home/jenkins/.docker/config.json"
                }
            }
        }
    }
    post {
     success {
        withCredentials([string(credentialsId: 'jenkins_polar_bot', variable: 'TOKEN'), string(credentialsId: 'chatWebid', variable: 'CHAT_ID')]) {
            sh  ("""
            curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : OK *Published* = YES'
            """)
        }
    }

     aborted {
        withCredentials([string(credentialsId: 'jenkins_polar_bot', variable: 'TOKEN'), string(credentialsId: 'chatWebid', variable: 'CHAT_ID')]) {
            sh  ("""
            curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : `Aborted` *Published* = `Aborted`'
            """)
        }
    }
     
     failure {
        withCredentials([string(credentialsId: 'jenkins_polar_bot', variable: 'TOKEN'), string(credentialsId: 'chatWebid', variable: 'CHAT_ID')]) {
            sh  ("""
            curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC  *Branch*: ${env.GIT_BRANCH} *Build* : `not OK` *Published* = `no`'
            """)
        }
    }

 }
}
```


```groovy
pipeline {
    agent {
       node{
          label 'agent-secondary'
        }    
    }
    stages {
        stage('Preparation') { // for display purposes
            steps {
                sh 'apk update && apk add ansible'
                sh 'ansible-galaxy role install --role-file /tmp/requirements.yml --roles-path ./roles'
                sh 'docker pull morsh92/molecule:dind'
            }
        }
        stage('Test') {
            steps {
                sh '[ -d ./molecule ] || mkdir molecule'
                sh 'rm -rf ./molecule/django || echo "absent"'
                sh 'docker rm molecule-django -f'
                sh 'docker run --rm -d --name=molecule-django -v  /home/jenkins/workspace/django-ansible-role/molecule:/opt/molecule -v  /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged morsh92/molecule:dind'
                sh 'docker exec molecule-django  /bin/sh -c  "molecule init role morsh92.django -d docker"'    
                sh 'cp -rf ./roles/django/* ./molecule/django'
                sh '[ -d ./molecule/django/molecule/default ] || mkdir -p ./molecule/django/molecule/default'
                sh 'mv ./molecule/django/molecule.yml ./molecule/django/molecule/default'
                sh 'mv ./molecule/django/verify.yml ./molecule/django/molecule/default'
                sh '[ -d /home/jenkins/workspace/django-ansible-role/molecule/django/roles ] || mkdir -p /home/jenkins/workspace/django-ansible-role/molecule/django/roles'
                sh 'rm -rf ./molecule/django/meta'
                sh 'mkdir -p molecule/django/molecule/default/roles/morsh92.django && cp -rf ./roles/django/* ./molecule/django/molecule/default/roles/morsh92.django'
                sh 'rm -rf ./molecule/django/molecule/default/roles/morsh92.django/meta'
                sh 'cp -rf ./roles/Infrastructure/postgresql ./molecule/django/molecule/default/roles'
                sh 'cp -rf ./roles/Infrastructure/docker ./molecule/django/molecule/default/roles'
                sh 'docker exec  molecule-django  /bin/sh -c  "cd ./django && molecule create"'
                sh 'docker exec  molecule-django  /bin/sh -c  "cd ./django && molecule converge"'
                sh 'docker exec  molecule-django  /bin/sh -c  "cd ./django && molecule verify"'
            }
        }
        stage('Deploy'){
            steps {
                sh 'echo "done!"'
            }    
        }
    }
}
```


# [MyAwsomeJenkins](http://158.160.32.253:8080/)

> Это только начало, инструмент большой, попробую еще установить xray, и настроить все через API. А с заданием считаю справился :smile:


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_ansiblevault"></a> [ansiblevault](#requirement\_ansiblevault) | = 2.2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | ~> 0.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansiblevault"></a> [ansiblevault](#provider\_ansiblevault) | 2.2.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.3.0 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_morsh_instance_ya_1"></a> [morsh\_instance\_ya\_1](#module\_morsh\_instance\_ya\_1) | ./INSTANCE | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.yc_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [yandex_vpc_network.morsh-network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.morsh-subnet-a](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |
| [ansiblevault_path.jenkins_agent_1_secret](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.jenkins_agent_2_secret](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.jenkins_archive_password](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |
| [ansiblevault_path.ssh_server_pub](https://registry.terraform.io/providers/MeilleursAgents/ansiblevault/2.2.0/docs/data-sources/path) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id_yandex"></a> [cloud\_id\_yandex](#input\_cloud\_id\_yandex) | Cloud id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_folder_id_yandex"></a> [folder\_id\_yandex](#input\_folder\_id\_yandex) | Folder id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_network_name_yandex"></a> [network\_name\_yandex](#input\_network\_name\_yandex) | Created netowork in yandex.cloud name | `string` | n/a | yes |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Size of required vm | `string` | `"50"` | no |
| <a name="input_service_account_key_yandex"></a> [service\_account\_key\_yandex](#input\_service\_account\_key\_yandex) | Local storing service key. Not in git tracking | `string` | `"./key.json"` | no |
| <a name="input_source_image"></a> [source\_image](#input\_source\_image) | OS family of image | `string` | `"ubuntu-2004-lts"` | no |
| <a name="input_subnet_a_description_yandex"></a> [subnet\_a\_description\_yandex](#input\_subnet\_a\_description\_yandex) | n/a | `string` | `"Subnet A for morshimus instance A"` | no |
| <a name="input_subnet_a_name_yandex"></a> [subnet\_a\_name\_yandex](#input\_subnet\_a\_name\_yandex) | Subnet for 1st instance | `string` | `"morsh-subnet-a"` | no |
| <a name="input_subnet_a_v4_cidr_blocks_yandex"></a> [subnet\_a\_v4\_cidr\_blocks\_yandex](#input\_subnet\_a\_v4\_cidr\_blocks\_yandex) | IPv4 network for 1st instance subnet | `list(string)` | <pre>[<br>  "192.168.21.0/28"<br>]</pre> | no |
| <a name="input_useros"></a> [useros](#input\_useros) | OS native default user | `string` | `"ubuntu"` | no |
| <a name="input_zone_yandex_a"></a> [zone\_yandex\_a](#input\_zone\_yandex\_a) | Zone of 1st instance in yandex cloud | `string` | `"ru-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ip_address_vm_1"></a> [external\_ip\_address\_vm\_1](#output\_external\_ip\_address\_vm\_1) | n/a |
| <a name="output_hostname_vm_1"></a> [hostname\_vm\_1](#output\_hostname\_vm\_1) | n/a |
| <a name="output_internal_ip_address_vm_1"></a> [internal\_ip\_address\_vm\_1](#output\_internal\_ip\_address\_vm\_1) | n/a |
| <a name="output_jenkins_agent_1_secret"></a> [jenkins\_agent\_1\_secret](#output\_jenkins\_agent\_1\_secret) | n/a |
| <a name="output_jenkins_agent_2_secret"></a> [jenkins\_agent\_2\_secret](#output\_jenkins\_agent\_2\_secret) | n/a |
| <a name="output_jenkins_archive_password"></a> [jenkins\_archive\_password](#output\_jenkins\_archive\_password) | n/a |
| <a name="output_ssh_key_server_pub"></a> [ssh\_key\_server\_pub](#output\_ssh\_key\_server\_pub) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
