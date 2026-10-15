# SouthCAP_BPAI

Solução Microsoft Fabric para ingestão, cálculo e logging de dados, com CI/CD via GitHub e deployment pipelines.

## Estrutura do repositório

```
/workspace/    Item definitions do Fabric (Git folder do workspace dev)
/README.md     Este ficheiro
```

## Ambientes

| Ambiente | Workspace | Capacidade | Ligação Git |
|----------|-----------|------------|-------------|
| dev      | SouthCAP_BPAI - dev  | F SKU própria | `main` |
| test     | SouthCAP_BPAI - test | F SKU própria | via deployment pipeline |
| prod     | SouthCAP_BPAI - prod | F SKU própria | via deployment pipeline |

## Fluxo de desenvolvimento

1. Criar uma feature branch a partir de `main` com **Branch out to workspace** no workspace `dev`.
   - Convenção de nomes: `feature/<ticket>-<descricao-curta>`, por exemplo `feature/DATA-123-margem-calculo`.
2. Fazer as alterações apenas no feature workspace.
3. Fazer **Commit** para a feature branch com uma mensagem clara.
4. Abrir um Pull Request para `main` e pedir revisão a outra pessoa da equipa, sempre que possível.
5. Fazer merge em `main` e executar **Update from Git** no workspace `dev`.
6. Apagar a feature branch e o feature workspace.

## Regras

- Não fazer alterações diretas no workspace `dev` depois do setup inicial.
- Não fazer push direto para `main`.
- Manter as branches curtas (dias, não semanas).
- Não colocar credenciais, connection strings ou tokens no código. Usar variable libraries.
- Uma feature por branch.

## Deployment

O deploy entre ambientes é feito pela **deployment pipeline** do Fabric:

1. `dev` → `test`: após o merge em `main` e o Update from Git no `dev`.
2. `test` → `prod`: depois de validar em test.

Antes de promover para `prod`, confirmar que:
- Os itens funcionam em `test`.
- O value set `prod` da variable library está correto.
- O `LOG.Ingest` está a registar as execuções como esperado.

## Parametrização

Os valores que mudam entre ambientes ficam numa **variable library** (servidores, bases de dados, caminhos). Não são hardcoded nos notebooks nem nas definições dos itens.

## Base de dados

- Fabric SQL database com os schemas `LOG`, `CFG` e `BRZ`.
- `LOG.Ingest`: um registo por execução de ingestão, criado no início e atualizado no fim.
- `CFG.*`: tabelas de configuração, alteradas através dos stored procedures `CFG.usp_Insert*`.

## Equipa

Mínimo de 3 pessoas. Quem faz o Commit to Git inicial e as alterações a `main` deve estar combinado no início do projeto.

## Notas

- Os PRs são o registo das alterações. Usar a descrição para explicar o porquê, não só o quê.
- Se um deploy falhar, a pipeline mantém a versão anterior no ambiente de destino. Verificar o motivo antes de tentar de novo.