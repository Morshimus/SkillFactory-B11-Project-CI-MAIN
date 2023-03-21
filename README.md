# SkillFactory-B9-JFrog-Artifactory-MAIN

## [Jenkins-Cluster-Role](https://github.com/Morshimus/SkillFactory-B11-Project-CI-Role-CI-Jenkins-Cluster)


## [Django-Application-SF-Role](https://github.com/Morshimus/SkillFactory-B11-Project-CI-Role-APP)

## [Infrastructire-Docker+Postgresql-Role](https://github.com/Morshimus/SkillFactory-B11-Project-CI-Role-INFRA)


## [Django-Application-SF-Docker-APP](https://github.com/Morshimus/SkillFactory-B11-Project-CI-APP)

## Задание

* [x] - :one: **Создать в Я.Облаке виртуальную машину со следующими характеристиками: ~~2~~4vCPU, ~~2~~4GB, RAM, ~~20~~50GB, ~~HDD~~SSD.**
* [x] - :two:**Поднять на этой машине CI-сервер на ваш выбор.**
> Был поднят [Jenkins](http://158.160.32.253:8080/)
![image](https://am3pap003files.storage.live.com/y4mGAmaTiInvZyNUPUeqTes34My-XUgQacFFJwSUHBL3GlSoGgmoSuUMjV81ahc1JFtZ92vB-721DK22v0EMnd4fp53fpmTtPzof0TfYqDVV7bshLF5RI90BjNLnQnsgBfN3LmpxWuV8f9-647clto5WRQDpkEBmX0iY1cPTPVfGr6kfN4cbY2Be16ArfVIv2fb?encodeFailures=1&width=1767&height=801)
Для Агентов был создан отдельный образ в Dockerfile с dind:

**Dockerfile:**
```Dockerfile
FROM docker:dind
ARG AGENT_VER=2.38

ARG USER=jenkins
ARG GROUP=jenkins
ARG UID=1024
ARG GID=1024

ARG AGENT_WORKDIR=/home/${USER}/agent
ENV HOME /home/${USER}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

COPY dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
COPY agent.jar   /usr/share/jenkins/slave.jar

RUN addgroup -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -g "${USER} service" \
         -u ${UID} -G ${GROUP} ${USER} \
    && set -x \
    && apk add --update --no-cache \
         curl \
         bash \
         git \
         openssh-client \
         openssl \
         procps \
         openjdk11 \
    && printf "\n### Installing Jenkins agent v${AGENT_VER} ###\n\n" \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar \
    && mkdir ${HOME}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR} \
    && chown -R ${USER}:${GROUP} ${HOME} \
#    && chmod +x /usr/local/bin/jenkins-agent \
    && printf "\n### Cleaning up ###\n\n" \
    && apk del --purge -v \
         curl

#VOLUME ${HOME}/.jenkins
#VOLUME ${AGENT_WORKDIR}

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk/

ENV JAVA_BIN="$JAVA_HOME/bin/java"

ENV JENKINS_URL=""
ENV JENKINS_AGENT_NAME=""
ENV JENKINS_AGENT_WORKDIR=""
ENV JENKINS_SECRET_FILE=""

WORKDIR ${HOME}


USER root


ENTRYPOINT ["dockerd-entrypoint.sh"]
```

**Docke-compose:**
```yaml
version: '3.8'

secrets:
 agent-1-secret:
  file: .agent_1_secret
 agent-2-secret:
  file: .agent_2_secret

x-agent-image: &Agent_Image "${DOCKER_IMG_agent:-morsh92/jenkins-agent-dind:alpine}" 
x-agent-user: &Agent_User "${DOCKER_USER_agent:-root}"
x-agent-volumes: &Agent_Volumes
  - ./agents_share:/tmp:rw
x-agent-1-cpu: &Agent_1_CPU "${DOCKER_agent_1_CPUS:-1}"
x-agent-1-mem: &Agent_1_MEM "${DOCKER_agent_1_MEMORY:-512MB}"
x-agent-2-cpu: &Agent_2_CPU "${DOCKER_agent_2_CPUS:-1}"
x-agent-2-mem: &Agent_2_MEM "${DOCKER_agent_2_MEMORY:-724MB}"
x-agent-1-env: &Agent_1_ENV
  - JENKINS_SECRET_FILE=/run/secrets/agent-1-secret
  - JENKINS_URL=http://master:8080
  - JENKINS_AGENT_NAME=agent-1
  - JENKINS_AGENT_WORKDIR=/home/jenkins
x-agent-2-env: &Agent_2_ENV
  - JENKINS_SECRET_FILE=/run/secrets/agent-2-secret
  - JENKINS_URL=http://master:8080
  - JENKINS_AGENT_NAME=agent-2
  - JENKINS_AGENT_WORKDIR=/home/jenkins
x-agent-1-secrets: &Agent_1_Secret
  - agent-1-secret
x-agent-2-secrets: &Agent_2_Secret
  - agent-2-secret

x-logging: &logging
 driver: "json-file"
 options:
   max-size: "100m"
   max-file: "1"


services:
 jenkins-main:
  image: "${DOCKER_IMG_main:-jenkins/jenkins:lts}"
  privileged: true
  user: "${DOCKER_USER_main:-root}"
  deploy:
    resources:
      limits:
        cpus: "${DOCKER_main_CPUS:-2}"
        memory: "${DOCKER_main_MEMORY:-2GB}"
  restart: unless-stopped
  healthcheck:
    test: curl -I http://master:8080/login --max-time 5 | grep 200
    interval: 5s
    timeout: 10s
    start_period: 180s
    retries: 10
  sysctls:
   - net.ipv4.ip_local_port_range=1024 65000
   - net.ipv4.conf.all.accept_redirects=0
   - net.ipv4.conf.all.secure_redirects=0
   - net.ipv4.conf.all.send_redirects=0
  networks:
   backend:
     aliases:
        - master
   frontend:
  ports:
   - "8080:8080"
   - "50000:50000"
  volumes:   
   - ./home:/var/jenkins_home:rw
   - /var/run/docker.sock:/var/run/docker.sock
  logging: *logging

 
 jenkins-agent-1: 
   image: *Agent_Image
   user: *Agent_User
   privileged: true
   deploy: 
    resources:
      limits:
        cpus: *Agent_1_CPU
        memory: *Agent_1_MEM
   restart:  unless-stopped
   depends_on:
    jenkins-main:
     condition: service_healthy
   sysctls: 
    - net.ipv4.ip_local_port_range=1024 65000
    - net.ipv4.conf.all.accept_redirects=0
    - net.ipv4.conf.all.secure_redirects=0
    - net.ipv4.conf.all.send_redirects=0
   environment: *Agent_1_ENV
   secrets: *Agent_1_Secret
   networks: 
    frontend:
    backend:
      aliases:
         - slave-1
   volumes: *Agent_Volumes
   logging: *logging

 jenkins-agent-2:
  image: *Agent_Image
  user: *Agent_User 
  privileged: true
  deploy: 
    resources:
      limits:
        cpus:  *Agent_2_CPU
        memory: *Agent_2_MEM
  restart:  unless-stopped
  depends_on:
    jenkins-main:
     condition: service_healthy
  sysctls:
    - net.ipv4.ip_local_port_range=1024 65000
    - net.ipv4.conf.all.accept_redirects=0
    - net.ipv4.conf.all.secure_redirects=0
    - net.ipv4.conf.all.send_redirects=0 
  environment: *Agent_2_ENV
  secrets: *Agent_2_Secret
  networks:
    frontend:
    backend:
      aliases:
         - slave-2
  volumes: *Agent_Volumes
  logging: *logging
  


networks:
 frontend:
   driver: bridge
   driver_opts:
      com.docker.network.enable_ipv6: "false"
   ipam:
     driver: default
     config:
      - subnet: 10.212.21.0/28
 backend:
   internal: true
   driver: bridge
   driver_opts:
     com.docker.network.enable_ipv6: "false"
   ipam:
     driver: default
     config:
      - subnet: 10.111.111.0/28       
```

* [x] :three: **Создать репозиторий (github/gitlab/проч. на ваше усмотрение) и создать там файл index.html.**
>В описании это **Django-Application-SF-Role** и **Django-Application-SF-Docker-APP**

* [x] - :four: **Настроить CI:**
   - *Запускающий контейнер с nginx (версия на ваше усмотрение) с пробросом порта 80 в порт 9889 хостовой системы. При обращении к nginx в контейнере по HTTP, nginx должен выдавать измененный файл index.html.*
   - *Проверяющий код ответа запущенного контейнера при HTTP-запросе (код должен быть 200).*
   - *Сравнивающий md5-сумму измененного файла с md5-суммой файла, отдаваемого nginx при HTTP-запросе     (суммы должны совпадать).*
   - *Триггер для старта CI: внесение изменений в созданный вами файл index.html из п.3. В случае выявления ошибки (в двух предыдущих пунктах), должно отправляться оповещение вам в удобный канал связи — Telegram/Slack/email. Текст оповещения — на ваше усмотрение.*
   ![image](https://am3pap003files.storage.live.com/y4mf5u0dn74SP7Sm90WPQjQVCCGk-0QxzJq-F-tod2AtBhaoLvTi4fswf6NGDV8D331qaq-X8klfkCwbuz-FCWJ-VIyMh4uo9NXL8fSTftraBonw-mbCqRmSFOWiguMD8_oqYZHFcdQlnWoNUGrJHJNobj3-tsBcF4Ji9c_08MUmVrKEHDJthQtYWfF6XtAmoTg?encodeFailures=1&width=1767&height=733)
   ![image](https://am3pap003files.storage.live.com/y4mJ-KvWhq2wzdLUmYjKTkaah_ZrNhwK0KTUAOGSfOGRoJ2n-mBUzzlzjV5Ca8MeE2kLL8MuUkGka3G9c2EsYgTNo6HzK1UWAvGFYAeit8KfLB4O0GOe-bFb2zktSfR1XPMkoIfq2Zd-PnuleGQTQZ1qUIwdoliNu6cQafsSL1N6Bd_HZ1OTbyLE8TKkOLbxYRM?encodeFailures=1&width=419&height=801)
   
   - *После выполнения CI созданный контейнер удаляется.*


* [x] - :five: **Прислать ментору написанный вами для CI код (или скрин с описанием джоба), а также ссылку на репозиторий и на развернутую CI-систему.**

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
