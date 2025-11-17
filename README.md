# thehanddler.sh

Script para gerenciamento de vaults de projetos - deploy e arquivamento.

## Uso

```bash
# Deploy de um novo vault
sudo ./thehanddler.sh <nome_do_projeto>

# Arquivar um vault existente
sudo ./thehanddler.sh <nome_do_projeto> --arquivar
```

## Exemplos

```bash
# Criar vault para projeto "cliente01"
sudo /home/fff37/scripts/thehanddler.sh "cliente01"

# Arquivar vault do projeto "cliente01"
sudo /home/fff37/scripts/thehanddler.sh "cliente01" --arquivar

# Via workflow n8n
sudo /home/fff37/scripts/thehanddler.sh "{{ $json.vault_name }}"
```

## Funcionalidades

### 1. Deploy de Vault

Quando executado sem `--arquivar`, o script cria a estrutura completa de um projeto:

#### Estrutura de Diretórios

```
/projects/<nome_do_projeto>/
├── vault/           # Template do Obsidian (copiado de /root/template-2025)
├── targets/         # Alvos do projeto (dumps, exploits, recon)
├── screenshots/     # Capturas de tela
├── logs/            # Logs do projeto
└── operators/       # Diretório dos operadores
```

#### Configuração de Grupos

- **operators**: Grupo global para todos os operadores
- **<nome_do_projeto>**: Grupo específico do projeto

#### Configuração de Usuários

Para cada operador listado em `/home/fff37/scripts/operators`:
- Cria usuário com shell `/bin/bash`
- Adiciona ao grupo `operators` (primário) e `<nome_do_projeto>` (secundário)
- Cria home em `/home/<operador>`
- Copia atalho do Obsidian para o Desktop
- Cria link simbólico do projeto no Desktop
- Gera senha aleatória de 16 caracteres (usando pwgen)

#### Permissões

- ACL: `g:<nome_do_projeto>:rwx` com herança
- Ownership: `root:<nome_do_projeto>`
- Permissões: `g+ws` (setgid para herança de grupo)

### 2. Arquivamento de Vault

Quando executado com `--arquivar`, o script:

1. **Verifica existência** do vault em `/projects/<nome_do_projeto>/vault`
2. **Cria diretório de arquivo** em `/projects/archived/<data_atual>/`
3. **Move o vault** para o diretório de arquivo
4. **Compacta** em `.tar.gz` com nome `<projeto>_vault_<data>.tar.gz`
5. **Move o projeto** para `/root/` como backup
6. **Define permissões read-only** (chmod 400)

#### Estrutura de Arquivo

```
/projects/archived/2025-01-15/
└── cliente01_vault_2025-01-15.tar.gz

/root/cliente01/  # Backup do projeto (read-only)
```

## Arquivos de Configuração

### /home/fff37/scripts/operators

Arquivo com lista de operadores (um por linha ou separados por vírgula):

```
operador1
operador2
operador3
```

## Dependências

- `tree` - Visualização de diretórios
- `pwgen` - Geração de senhas seguras
- `setfacl` - Configuração de ACLs

Instale com:
```bash
apt install tree pwgen acl -y
```

## Variáveis Principais

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `PROJECT_NAME` | Nome do projeto (argumento $1) | - |
| `OPERATORS_FILE` | Arquivo com lista de operadores | `/home/fff37/scripts/operators` |
| `WORKDIR` | Diretório base dos projetos | `/projects` |
| `PROJECT_DIR` | Diretório completo do projeto | `/projects/<nome_do_projeto>` |

## Integração com n8n

O script é projetado para ser chamado via workflows n8n. Exemplo de comando SSH no n8n:

```bash
sudo /home/fff37/scripts/thehanddler.sh "{{ $json.vault_name }}" | tee -a /tmp/log-deploy
```

Para arquivamento via n8n:
```bash
sudo /home/fff37/scripts/thehanddler.sh "{{ $json.vault_name }}" --arquivar | tee -a /tmp/log-archive
```

## Fluxo de Trabalho Típico

1. **Novo Projeto**: Webhook dispara workflow n8n que executa o script de deploy
2. **Durante Projeto**: Operadores acessam via Obsidian em `/share/<projeto>/vault/`
3. **Fim do Projeto**: Workflow n8n executa script com `--arquivar` para arquivar

## Observações

- O script requer privilégios de root (sudo)
- Se o projeto já existir, o deploy não sobrescreve (exit manual assessment)
- O arquivamento verifica se o vault existe antes de prosseguir
- Senhas geradas são exibidas apenas uma vez durante a criação
- O template do Obsidian é copiado de `/root/template-2025`

## Logs

Para manter logs das operações:

```bash
# Deploy com log
sudo ./thehanddler.sh "projeto01" | tee -a /tmp/log-deploy

# Arquivamento com log
sudo ./thehanddler.sh "projeto01" --arquivar | tee -a /tmp/log-archive
```
