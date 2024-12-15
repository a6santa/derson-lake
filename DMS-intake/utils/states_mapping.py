"""
Módulo para gerenciamento de recursos do AWS Database Migration Service (DMS).

Fornece uma classe para criar e gerenciar instâncias de replicação,
tarefas e endpoints do DMS através da API da AWS.
"""

import json
import boto3

from utils.dms import DMS

def get_endpoint_arn_by_name(endpoint_name: str) -> str:
    """
    Função que busca o ARN do endpoint pelo nome usando boto3
    
    Parameters
    ----------
    endpoint_name : str
        Nome do endpoint que deseja buscar
        
    Returns
    -------
    str
        ARN do endpoint encontrado
    """
    try:
        dms_client = boto3.client('dms', region_name='sa-east-1')
        response = dms_client.describe_endpoints()
        
        for endpoint in response['Endpoints']:
            if endpoint['EndpointIdentifier'] == endpoint_name:
                return endpoint['EndpointArn']
        raise ValueError(f"Endpoint não encontrado: {endpoint_name}")
    except Exception as e:
        raise Exception(f"Erro ao buscar endpoint {endpoint_name}: {str(e)}") from e

def get_owner_mapping() -> dict:
    """
    Função que retorna as configurações necessárias para criar a instancia e task
    """
    return {
        "instance_type": "dms.t3.large",
        "mapping_path": "utils/configs/mapping.json",
        "settings_path": "utils/configs/task_settings.json",
        "source": get_endpoint_arn_by_name("mysql-endpoint-source-1"),
        "target": get_endpoint_arn_by_name("s3-lake-endpoint-1"),
        "instance_name": "derson",
        "service": "derson_db",
    }


def select_step(step: str, owner_name: str, delta: bool) -> str:
    """
    Função que adiciona seleciona o próximo passo
    que a máquina de estados(step-functions) irá tomar.
    Parameters
    ----------
    step:str
        String que indica qual o passo a ser executado
    owner_name:str
        Owner da account de DMS
    delta:bool
        Booleano que indica se o D-1 está ativo ou não.
    """
    dms = DMS()

    initial_mapping = get_owner_mapping()

    selected_machine_size = initial_mapping["instance_type"]
    owner_source_arn = initial_mapping["source"]
    owner_target_arn = initial_mapping["target"]
    mapping_path = initial_mapping["mapping_path"]
    settings_path = initial_mapping["settings_path"]
    instance_name = initial_mapping["instance_name"]
    service = initial_mapping["service"]

    with open(mapping_path, encoding='utf-8') as mapping:
        json_mapping = json.load(mapping)
    with open(settings_path, encoding='utf-8') as settings:
        json_settings = json.load(settings)

    if step == "create_instance":
        sg_list = ["sg-bd7855d8", "sg-9bf73afc"]
        subnet="default-vpc-cf311baa"

        response = dms.create_replication_instance(
            name=instance_name,
            machine_size=selected_machine_size,
            security_group_list=sg_list,
            subnetgroup=subnet
        )
        return response["instance_status"]

    elif step == "check_instance_status":
        response = dms.get_instance_infos(name=instance_name)

        return response["instance_status"]

    elif step == "create_replication_task":
        print(instance_name)
        instance_arn = dms.get_instance_infos(instance_name)["instance_arn"]

        if delta:
            dms.update_endpoint_target(owner_target_arn, service)
            json_mapping = json.loads(dms.date_fullfilment(mapping_path))

        response = dms.create_replication_task(
            name=owner_name,
            source_arn=owner_source_arn,
            target_arn=owner_target_arn,
            instance_arn=instance_arn,
            table_mappings=json_mapping,
            task_definitions=json_settings,
            instance_name=instance_name,
        )
        return response["task_status"]

    elif step == "start_replication_task":
        task_arn = dms.get_task_infos(owner_name)["task_arn"]
        response = dms.start_replication_task(task_arn)
        return response

    elif step == "check_replication_task_status":
        response = dms.get_task_infos(owner_name)

        return response["status"]

    elif step == "delete_task":
        task_arn = dms.get_task_infos(owner_name)["task_arn"]
        response = dms.delete_replication_task(task_arn)
        return "Deleting Task"

    elif step == "delete_instance":
        instance_arn = dms.get_instance_infos(name=instance_name)["instance_arn"]
        response = dms.delete_replication_instance(instance_arn)
        return "Deleting Instance"

    else:
        raise Exception(f"Unknown step: {step}")
