# SkillFactory-B9-JFrog-Artifactory-MAIN

## [Roles](https://github.com/Morshimus/SkillFactory-B9-JFrog-Artifactory-Roles)

## Задание

* [x] **Создать в Я.Облаке виртуальную машину со следующими характеристиками: 2vCPU, 2GB, RAM, 20GB, HDD.**
* [x] **Поднять на этой машине CI-сервер на ваш выбор.**
> Был поднят [Jenkins](http://158.160.32.253:8080/)
![image](https://am3pap003files.storage.live.com/y4mGAmaTiInvZyNUPUeqTes34My-XUgQacFFJwSUHBL3GlSoGgmoSuUMjV81ahc1JFtZ92vB-721DK22v0EMnd4fp53fpmTtPzof0TfYqDVV7bshLF5RI90BjNLnQnsgBfN3LmpxWuV8f9-647clto5WRQDpkEBmX0iY1cPTPVfGr6kfN4cbY2Be16ArfVIv2fb?encodeFailures=1&width=1767&height=801)

* [x] **Создать репозиторий (github/gitlab/проч. на ваше усмотрение) и создать там файл index.html.**

Настроить CI:
Запускающий контейнер с nginx (версия на ваше усмотрение) с пробросом порта 80 в порт 9889 хостовой системы. При обращении к nginx в контейнере по HTTP, nginx должен выдавать измененный файл index.html.
Проверяющий код ответа запущенного контейнера при HTTP-запросе (код должен быть 200).
Сравнивающий md5-сумму измененного файла с md5-суммой файла, отдаваемого nginx при HTTP-запросе (суммы должны совпадать).
Триггер для старта CI: внесение изменений в созданный вами файл index.html из п.3. В случае выявления ошибки (в двух предыдущих пунктах), должно отправляться оповещение вам в удобный канал связи — Telegram/Slack/email. Текст оповещения — на ваше усмотрение.
После выполнения CI созданный контейнер удаляется.
Прислать ментору написанный вами для CI код (или скрин с описанием джоба), а также ссылку на репозиторий и на развернутую CI-систему.

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
