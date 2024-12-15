"""
Módulo para gerenciamento de recursos do AWS Database Migration Service (DMS).

Fornece uma classe para criar e gerenciar instâncias de replicação,
tarefas e endpoints do DMS através da API da AWS.
"""

import json
from datetime import datetime, timedelta

import boto3


class DMS(object):
    """
    Gerencia operações do AWS Database Migration Service (DMS).
    
    Fornece métodos para criar e gerenciar instâncias de replicação,
    tarefas de replicação e endpoints do DMS.
    """
    def __init__(self):
        self.client = boto3.client("dms")

    def create_replication_instance(
        self, name: str, machine_size: str, security_group_list: list, subnetgroup: str
    ):
        """
        Cria uma nova instância de replicação no DMS.

        Args:
            name: Nome da instância
            machine_size: Tipo da instância
            security_group_list: Lista de grupos de segurança
            subnetgroup: Grupo de subnet

        Returns:
            dict: Status e nome da instância criada
        """
        response = self.client.create_replication_instance(
            ReplicationInstanceIdentifier=f"{name}-dms-replication-instance",
            AllocatedStorage=50,
            AvailabilityZone="sa-east-1c",
            ReplicationInstanceClass=machine_size,
            VpcSecurityGroupIds=security_group_list,
            PreferredMaintenanceWindow="sun:06:00-sun:06:30",
            MultiAZ=False,
            EngineVersion="3.5.3",
            AutoMinorVersionUpgrade=False,
            ReplicationSubnetGroupIdentifier=subnetgroup,
            PubliclyAccessible=True,
        )
        return {
            "instance_status": response["ReplicationInstance"][
                "ReplicationInstanceStatus"
            ],
            "instance_name": response["ReplicationInstance"][
                "ReplicationInstanceIdentifier"
            ],
        }

    def get_instance_infos(self, name):
        """
        Obtém informações de uma instância de replicação.

        Args:
            name: Nome da instância

        Returns:
            dict: Status, nome e ARN da instância
        """
        response = self.client.describe_replication_instances(
            Filters=[
                {
                    "Name": "replication-instance-id",
                    "Values": [
                        f"{name}-dms-replication-instance",
                    ],
                }
            ]
        )
        return {
            "instance_status": response["ReplicationInstances"][0][
                "ReplicationInstanceStatus"
            ],
            "instance_name": response["ReplicationInstances"][0][
                "ReplicationInstanceIdentifier"
            ],
            "instance_arn": response["ReplicationInstances"][0][
                "ReplicationInstanceArn"
            ],
        }

    def create_replication_task(
        self, name, source_arn, target_arn, table_mappings, task_definitions, instance_name, **kwargs,
    ):
        """
        Cria uma nova tarefa de replicação.

        Args:
            name: Nome da tarefa
            source_arn: ARN do endpoint fonte
            target_arn: ARN do endpoint destino
            table_mappings: Mapeamento das tabelas
            task_definitions: Configurações da tarefa
            instance_name: Nome da instância de replicação

        Returns:
            dict: Nome, ARN e status da tarefa criada
        """
        instance_arn = self.get_instance_infos(instance_name)["instance_arn"]

        response = self.client.create_replication_task(
            ReplicationTaskIdentifier=f"{name}-full-load",
            SourceEndpointArn=source_arn,
            TargetEndpointArn=target_arn,
            ReplicationInstanceArn=instance_arn,
            MigrationType="full-load",
            TableMappings=json.dumps(table_mappings), 
            ReplicationTaskSettings=json.dumps(task_definitions)
        )
        return {
            "task_name": response["ReplicationTask"]["ReplicationTaskIdentifier"],
            "task_arn": response["ReplicationTask"]["ReplicationTaskArn"],
            "task_status": response["ReplicationTask"]["Status"]
        }

    def start_replication_task(self, task_arn):
        """
        Inicia uma tarefa de replicação.

        Args:
            task_arn: ARN da tarefa

        Returns:
            str: Status da tarefa
        """
        response = self.client.start_replication_task(
            ReplicationTaskArn=task_arn, StartReplicationTaskType="reload-target"
        )
        return response["ReplicationTask"]["Status"]

    def delete_replication_instance(self, instance_arn):
        """
        Remove uma instância de replicação.

        Args:
            instance_arn: ARN da instância

        Returns:
            dict: Resposta da API do DMS
        """
        response = self.client.delete_replication_instance(
            ReplicationInstanceArn=instance_arn
        )
        return response

    def delete_replication_task(self, task_arn):
        """
        Remove uma tarefa de replicação.

        Args:
            task_arn: ARN da tarefa

        Returns:
            dict: Resposta da API do DMS
        """
        response = self.client.delete_replication_task(ReplicationTaskArn=task_arn)
        return response

    def get_task_infos(self, name):
        """
        Obtém informações de uma tarefa de replicação.

        Args:
            name: Nome da tarefa

        Returns:
            dict: Tipo, status e ARN da tarefa
        """
        response = self.client.describe_replication_tasks(
            Filters=[
                {
                    "Name": "replication-task-id",
                    "Values": [
                        f"{name}-full-load",
                    ],
                }
            ]
        )

        type_ = response["ReplicationTasks"][0]["MigrationType"]
        status = response["ReplicationTasks"][0]["Status"]
        task_arn = response["ReplicationTasks"][0]["ReplicationTaskArn"]
        return {"type": type_, "status": status, "task_arn": task_arn}

    def update_endpoint_target(self, endpoint_arn, service):
        """
        Atualiza as configurações do endpoint de destino.

        Args:
            endpoint_arn: ARN do endpoint
            service: Nome do serviço

        Returns:
            str: ARN do endpoint atualizado
        """
        date = datetime.now()
        today = date.strftime("%Y-%m-%d")

        response = self.client.modify_endpoint(
            EndpointArn=endpoint_arn,
            S3Settings={"BucketFolder": f"{service}/delta/date={today}"},
        )
        return response["Endpoint"]["EndpointArn"]

    def date_fullfilment(self, path_to_json):
        """
        Atualiza a data de filtro no arquivo de mapeamento para o dia anterior.
        """
        yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        with open(path_to_json, "r", encoding='utf-8') as file:
            mapping = json.load(file)

        for rule in mapping["rules"]:
            if len(rule.get("filters", [])) == 0:
                pass
            else:
                rule["filters"][0]["filter-conditions"][0]["value"] = yesterday
        return json.dumps(mapping)
