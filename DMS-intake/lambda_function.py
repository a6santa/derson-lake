"""
Função Lambda para gerenciar operações do AWS Database Migration Service (DMS).

Processa eventos para criar e gerenciar instâncias de replicação,
tarefas e endpoints do DMS através de uma máquina de estados.
"""

import json
from utils.states_mapping import select_step


def lambda_handler(event, context):
    """
    Manipula eventos do AWS Lambda para gerenciar tarefas do DMS.

    Args:
        event: Dicionário contendo 'owner', 'step' e opcionalmente 'delta'
        context: Objeto de contexto do Lambda

    Returns:
        dict: Resposta contendo status, mensagem e detalhes da execução
    """
    owner = event["owner"]
    step = event["step"]
    delta = event.get("delta") or False

    response = select_step(step, owner, delta)
    return {
        "statusCode": 200,
        "body": json.dumps(f"Success triggering Lambda step: {step}"),
        "owner": owner,
        "response": response,
    }
