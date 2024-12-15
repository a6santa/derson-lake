# Derson Lake - Framework de Ingestão Dinâmica com AWS DMS

Este projeto é um framework completo para ingestão de dados usando AWS Database Migration Service (DMS), Lambda, Step Functions e S3. É um projeto educacional que demonstra como criar uma solução de ingestão de dados dinâmica e automatizada.

## 📋 Índice
- [Arquitetura](#-arquitetura)
- [Componentes](#-componentes)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Módulos Terraform](#-módulos-terraform)
- [Funções Lambda](#-funções-lambda)
- [Como Usar](#-como-usar)
- [Monitoramento](#-monitoramento)
- [Segurança](#-segurança)

## 🏗 Arquitetura

O projeto utiliza os seguintes serviços AWS:
- **AWS DMS**: Para migração/replicação de dados
- **AWS Lambda**: Para orquestração e automação
- **AWS Step Functions**: Para controle de fluxo
- **Amazon S3**: Para armazenamento dos dados
- **IAM**: Para gerenciamento de permissões
- **CloudWatch**: Para monitoramento e logs

## 🔧 Componentes

### 1. Módulos Terraform

#### DMS Endpoint (`modules/dms-endpoint`)
- Cria endpoints fonte (MySQL) e destino (S3)
- Configurável via variáveis
- Suporta diferentes tipos de compressão

#### DMS Instance (`modules/dms-instance`) (*Não implementado, usando a Lambda DMS-intake para criar de forma dinâmica*)
- Gerencia instâncias de replicação
- Configurações de rede e segurança
- Suporte a Multi-AZ

#### DMS Task (`modules/dms-task`)
- Define tarefas de replicação
- Configurações de logging
- Mapeamento de tabelas

#### IAM Role (`modules/iam-role`)
- Cria roles para diferentes serviços:
  - DMS
  - Lambda
  - Step Functions
  - Secrets Manager
  - Glue

#### Lambda (`modules/lambda`)
- Deploy de funções Lambda
- Configuração de logs
- Gerenciamento de dependências

#### Step Functions (`modules/step-function`) 

- Orquestração do fluxo de execução da Lambda DMS
- Gerenciamento de estados e transições
- Tratamento de erros e retentativas

### 2. Função Lambda DMS

A função principal (`DMS-intake/lambda_function.py`) cria a instância e a tarefa de replicação e gerencia o ciclo de vida do DMS:

```python
def lambda_handler(event, context):
    """
    Manipula eventos para gerenciar tarefas DMS
    
    Parâmetros:
        event: Dict com 'owner', 'step' e 'delta'
        context: Contexto Lambda
    """
    owner = event["owner"]
    step = event["step"]
    delta = event.get("delta", False)
```

#### Estados da Lambda (`states_mapping.py`)

A função suporta os seguintes estados:

1. `create_instance`: Cria uma nova instância DMS
2. `check_instance_status`: Verifica o status da instância
3. `create_replication_task`: Cria uma nova tarefa de replicação
4. `start_replication_task`: Inicia a tarefa de replicação
5. `check_replication_task_status`: Monitora o status da tarefa
6. `delete_task`: Remove a tarefa de replicação
7. `delete_instance`: Remove a instância DMS

#### Utilitários DMS (`utils/dms.py`)

Classe principal com métodos para:
- Criar e gerenciar instâncias de replicação
- Configurar e monitorar tarefas
- Atualizar endpoints
- Gerenciar mapeamentos de tabelas
- Controlar configurações de logging

### 3. Step Functions (Pipelines)

O projeto utiliza três principais Step Functions para orquestrar o fluxo de dados:

#### derson-Main
Pipeline principal que orquestra todo o fluxo de ingestão:
- Inicia o processo de ingestão dos dados
- Gerencia a execução do DMS-Handler
- Monitora o status das execuções
- Formato do evento de entrada:
```json
{
    "owner": "dersonLake"
}
```

#### DMS-Handler
Gerencia o ciclo de vida do DMS usando a Lambda DMS-intake:
1. Cria instância DMS
2. Verifica status da instância
3. Cria tarefa de replicação
4. Inicia replicação
5. Monitora status
6. Remove recursos após conclusão

#### DMS-ErrorHandling
Pipeline de tratamento de erros:
- Monitora falhas nas execuções
- Realiza retentativas automáticas
- Notifica em caso de falhas persistentes
- Limpa recursos em caso de erro

### Fluxo de Execução

1. **Início**: Pipeline derson-Main é acionada
2. **DMS-Handler**: 
   - Cria recursos DMS
   - Gerencia replicação
   - Monitora execução
3. **Tratamento de Erros**:
   - DMS-ErrorHandling é acionado em caso de falhas
   - Tenta recuperar automaticamente
   - Notifica equipe se necessário

### Como Executar as Pipelines

1. Iniciar pipeline principal:
```bash
aws stepfunctions start-execution \
  --state-machine-arn "arn:aws:states:REGION:ACCOUNT:stateMachine:derson-Main" \
  --input '{"owner": "dersonLake"}'
```

2. Monitorar execução:
```bash
aws stepfunctions get-execution-history \
  --execution-arn "arn:aws:states:REGION:ACCOUNT:execution:derson-Main:EXECUTION_ID"
```

3. Verificar status:
```bash
aws stepfunctions describe-execution \
  --execution-arn "arn:aws:states:REGION:ACCOUNT:execution:derson-Main:EXECUTION_ID"
```
4. Caso queira usar o console para iniciar a execução, basta ir para o console do step functions e iniciar a execução do pipeline derson-Main.

### Configuração das Pipelines

#### derson-Main (`pipelines/derson-Main/states.json`)
```json
{
  "Comment": "Pipeline de dados dersonLake",
  "StartAt": "IntakeProdDB",
  "States": {
    "IntakeProdDB": {
      "Type": "Task",
      "Resource": "arn:aws:states:::states:startExecution.sync:2",
      "Parameters": {
        "StateMachineArn": "arn:aws:states:sa-east-1:123456789012:stateMachine:DMS-Handler",
        "Input": {
          "owner": "dersonLake"
        }
      },
      "End": true
    }
  }
}
```

#### Tratamento de Erros
O DMS-ErrorHandling implementa:
- Retentativas automáticas com backoff exponencial
- Limpeza de recursos em caso de falha
- Notificações via SNS
- Logging detalhado em CloudWatch

### Monitoramento das Pipelines

1. **Console AWS Step Functions**:
   - Visualização gráfica do fluxo
   - Status em tempo real
   - Histórico de execuções

2. **CloudWatch**:
   - Métricas de execução
   - Logs detalhados
   - Alertas configuráveis

3. **Notificações**:
   - SNS para falhas
   - Alertas por email
   - Integrações customizadas

## 📁 Estrutura do Projeto

```
derson-lake/
├── DMS-intake/
│   ├── lambda_function.py      # Função Lambda principal
│   ├── requirements.txt        # Dependências Python
│   └── utils/
│       ├── dms.py             # Utilitários DMS
│       ├── states_mapping.py  # Mapeamento de estados
│       └── configs/
│           ├── mapping.json    # Configuração de tabelas
│           └── task_settings.json # Configurações DMS
├── modules/
│   ├── dms-endpoint/          # Módulo para endpoints
│   ├── dms-instance/          # Módulo para instâncias
│   ├── dms-task/             # Módulo para tarefas
│   ├── iam-role/             # Módulo para IAM
│   ├── lambda/               # Módulo para Lambda
│   └── step-functions/       # Módulo para Step Functions
├── pipelines/
│   ├── derson-Main/          # Pipeline principal
│   │   ├── main.tf          # Configuração Terraform
│   │   ├── states.json      # Definição da máquina de estados
│   │   └── vars.tf          # Variáveis
│   ├── DMS-ErrorHandling/    # Pipeline de tratamento de erros
│   │   ├── main.tf
│   │   ├── states.json
│   │   └── vars.tf
│   └── DMS-Handler/          # Pipeline de gerenciamento DMS
│       ├── main.tf
│       ├── states.json
│       └── vars.tf
├── main.tf                    # Configuração principal
├── makefile                   # Automação de comandos
└── README.md
```

## 🚀 Como Usar
Importante: Este projeto é um exemplo educacional e não deve ser usado em um ambiente de produção sem modificações.

### Pré-requisitos
1. AWS CLI configurado
2. Terraform instalado
3. Python 3.8+
4. Permissões AWS adequadas

### Configuração

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/derson-lake.git
```

2. Configure as credenciais AWS:
```bash
aws configure
```

3. Inicialize o Terraform:
```bash
cd derson-lake
make init
```

4. Aplique a infraestrutura:
```bash
terraform plan
terraform apply
```

## 🔧 Configurações Avançadas

### Mapeamento de Tabelas
O arquivo `mapping.json` permite configurar:
- Seleção de tabelas
- Filtros de dados
- Transformações de colunas

### Configurações de Task
O arquivo `task_settings.json` controla:
- Configurações de logging
- Tratamento de erros
- Performance da replicação

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Commit suas mudanças: `git commit -m 'Adiciona nova feature'`
4. Push para a branch: `git push origin feature/nova-feature`
5. Abra um Pull Request

## 📚 Recursos Adicionais

- [Documentação AWS DMS](https://aws.amazon.com/dms/)
- [AWS Lambda](https://aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Step Functions](https://aws.amazon.com/step-functions/)


## 📞 Suporte

Para questões e suporte:
1. Abra uma issue no GitHub
2. Consulte a documentação
3. Verifique os exemplos fornecidos
4. Caso queira aprender mais sobre dados contate-me pelo linkedin: https://www.linkedin.com/in/aldsantana/