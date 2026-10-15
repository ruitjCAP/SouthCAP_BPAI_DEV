# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "466919ae-3771-4757-a4e6-72f1c541b707",
# META       "default_lakehouse_name": "LH_SouthCapBPAI",
# META       "default_lakehouse_workspace_id": "1da2046f-38fb-403d-b19c-196ce4d62dbc",
# META       "known_lakehouses": [
# META         {
# META           "id": "466919ae-3771-4757-a4e6-72f1c541b707"
# META         }
# META       ]
# META     }
# META   }
# META }

# MARKDOWN ********************

# # NB_MASTER_SEMISTRUCTURED
# 
# Primeiro passo da pipeline `INGEST_BEGIN`. Percorre `Files/00-Inbox/<VersionCode>/`, decide o que está pronto
# a processar e devolve à pipeline a **lista de trabalho** em JSON.
# 
# 
# 
# Regras aplicadas, por ordem:
# 1. A pasta (VersionCode) tem registo em `CFG.Version`.
# 2. A pasta tem ficheiros e o registo é posterior ao ficheiro mais recente (upload terminado), com tolerância de 2 min.
# 3. O nome de cada ficheiro segue `ASSET_ORIGEM_TIPO_PERIODO-Vn` (ativo, origem, periodicidade e mês válidos).
# 4. O `Vn` do nome coincide com a pasta.
# 5. Todos os ficheiros válidos da submissão têm o mesmo ano.

# MARKDOWN ********************

# ## 1. Parâmetros

# PARAMETERS CELL ********************

# Esta célula pode ser sobreposta pela pipeline (célula de parâmetros).
DRY_RUN = True                 # True = só lê e mostra; não move nem escreve nada

# Só é usado com DRY_RUN = True. Simula um registo em CFG.Version para uma pasta que ainda
# não existe na BD, {versão: minutos depois do ficheiro mais recente}. Deixar {} em produção.
SIMULAR_REGISTO = {"V99": 5}

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 2. Configuração

# CELL ********************

from pathlib import Path
from datetime import datetime, timezone, timedelta
import re
import json
import struct

# Copiar do notebook do Balancete (não os partilhar fora da equipa)
SQL_SERVER   = "lhxlobjhxx2epmocll5nospfdi-n4ckehp3ha6ubmm4dfwojvrnxq.database.fabric.microsoft.com,1433"
SQL_DATABASE = "SouthCapBPAI-a6fb681e-152f-4452-a9b3-988fcdfbc1f3"

# Inbox: dois formatos de caminho para o mesmo sítio (Lakehouse por defeito)
INBOX_LOCAL = Path("/lakehouse/default/Files/00-Inbox")   # para ler com pathlib
INBOX_FILES = "Files/00-Inbox"                            # para notebookutils.fs

TOLERANCIA = timedelta(minutes=2)

ATIVOS = ["TOC", "OPE", "NOS", "EIF", "MXR", "CIM", "SC", "TDL"]

# Tipos confirmados até agora. Faltam: Movimento Tesouraria, Imobilizado, Permilagem, Indexes
# (acrescentar quando se souber o texto exato do nome nos ficheiros).
CONFIG_TIPOS = {
    "BALANCETE":    {"origem": "SENDYS", "periodicidade": "mensal", "pasta": "Balancete"},
    "EXTRATOCONTA": {"origem": "SENDYS", "periodicidade": "mensal", "pasta": "Extrato_Conta"},
    "CAPEX":        {"origem": "PM",     "periodicidade": "anual",  "pasta": "Capex"},
    "OPEX":         {"origem": "PM",     "periodicidade": "anual",  "pasta": "Opex"},
}

PADRAO_NOME = re.compile(
    r"^(?P<ativo>" + "|".join(ATIVOS) + r")"
    r"_(?P<origem>[A-Z]+)_(?P<tipo>[A-Z]+)"
    r"_(?P<periodo>\d{6}|\d{4})-(?P<versao>V\d+)\.xlsx?$",
    re.IGNORECASE,
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 3. Ligação à base de dados

# CELL ********************

import pyodbc
from sqlalchemy import create_engine, text



def _connect_fabric():
    token = notebookutils.credentials.getToken("https://database.windows.net/").encode("UTF-16-LE")
    token_struct = struct.pack(f"<I{len(token)}s", len(token), token)
    conn_str = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server={SQL_SERVER};"
        f"Database={SQL_DATABASE};"
        "Encrypt=yes;TrustServerCertificate=no;"
    )
    return pyodbc.connect(conn_str, attrs_before={1256: token_struct}, timeout=60)

# Pede um token novo sempre que abre uma ligação nova
engine = create_engine("mssql+pyodbc://", creator=_connect_fabric)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 4. Funções: validação do nome do ficheiro

# CELL ********************

def validar_nome(nome, pasta):
    """Devolve (ok, motivo, dados). Não toca em ficheiros, só analisa o nome."""
    m = PADRAO_NOME.match(nome)
    if not m:
        return False, "nome fora do padrão", None

    d = {k: v.upper() for k, v in m.groupdict().items()}

    if d["versao"] != pasta.upper():
        return False, f"o nome diz {d['versao']} mas a pasta é {pasta}", d

    cfg = CONFIG_TIPOS.get(d["tipo"])
    if cfg is None:
        return False, f"tipo desconhecido: {d['tipo']}", d

    if d["origem"] != cfg["origem"]:
        return False, f"origem {d['origem']} não é a esperada ({cfg['origem']}) para {d['tipo']}", d

    periodicidade = "mensal" if len(d["periodo"]) == 6 else "anual"
    if periodicidade != cfg["periodicidade"]:
        return False, f"{d['tipo']} deve ser {cfg['periodicidade']} mas o período é {periodicidade}", d

    if periodicidade == "mensal":
        mes, ano = int(d["periodo"][:2]), int(d["periodo"][2:])
        if not 1 <= mes <= 12:
            return False, f"mês inválido: {mes}", d
    else:
        mes, ano = None, int(d["periodo"])

    d.update({"mes": mes, "ano": ano, "periodicidade": periodicidade, "pasta_tipo": cfg["pasta"]})
    return True, "ok", d

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 5. Funções: versões e timing

# CELL ********************

def ler_versoes():
    """Lê CFG.Version. Só leitura (não dispara o Activator)."""
    with engine.connect() as c:
        rows = c.execute(text(
            "SELECT VersionId, VersionCode, CreatedAt, UpdatedAt FROM CFG.Version"
        )).fetchall()
    return {
        r[1].upper(): {"version_id": r[0], "created_at": r[2], "updated_at": r[3]}
        for r in rows
    }


def mtime_utc(p):
    """Hora de modificação do ficheiro em UTC, sem fuso (comparável com CreatedAt/UpdatedAt)."""
    return datetime.fromtimestamp(p.stat().st_mtime, tz=timezone.utc).replace(tzinfo=None)


def ficheiros_da_pasta(pasta):
    return [f for f in sorted(pasta.iterdir()) if f.is_file() and not f.name.startswith("~$")]


def decidir_pasta(codigo, versoes):
    """Devolve (decisao, motivo). decisao = 'PROCESSAR' ou 'IGNORAR'."""
    v = versoes.get(codigo.upper())
    if v is None:
        return "IGNORAR", "sem registo em CFG.Version"

    ficheiros = ficheiros_da_pasta(INBOX_LOCAL / codigo)
    if not ficheiros:
        return "IGNORAR", "pasta vazia"

    ult_ficheiro = max(mtime_utc(f) for f in ficheiros)
    registo = max(t for t in (v["created_at"], v["updated_at"]) if t is not None)

    if registo + TOLERANCIA >= ult_ficheiro:
        return "PROCESSAR", "upload terminado"
    return "IGNORAR", f"upload em curso (ficheiro {ult_ficheiro} é posterior ao registo {registo})"


def aplicar_simulacao(versoes):
    """Só em DRY_RUN: cria registos simulados (em memória) para pastas sem registo na BD."""
    sim = dict(versoes)
    for codigo, minutos in SIMULAR_REGISTO.items():
        pasta = INBOX_LOCAL / codigo
        if codigo.upper() in sim or not pasta.is_dir():
            continue
        ficheiros = ficheiros_da_pasta(pasta)
        if not ficheiros:
            continue
        ult = max(mtime_utc(f) for f in ficheiros)
        sim[codigo.upper()] = {"version_id": 999, "created_at": ult + timedelta(minutes=minutos),
                               "updated_at": None, "simulado": True}
    return sim

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 6. Função: construir a lista de trabalho

# CELL ********************

def construir_lista_trabalho(versoes):
    trabalho, rejeitados, ignoradas = [], [], []

    if not INBOX_LOCAL.is_dir():
        return trabalho, rejeitados, [{"pasta": "00-Inbox", "motivo": "pasta do Inbox não encontrada"}]

    for pasta in sorted(INBOX_LOCAL.iterdir()):
        if not pasta.is_dir():
            continue
        codigo = pasta.name

        decisao, motivo = decidir_pasta(codigo, versoes)
        if decisao == "IGNORAR":
            ignoradas.append({"pasta": codigo, "motivo": motivo})
            continue

        validos = []
        for f in ficheiros_da_pasta(pasta):
            ok, motivo_f, d = validar_nome(f.name, codigo)
            if ok:
                validos.append({
                    "version_id":    versoes[codigo.upper()]["version_id"],
                    "version_code":  codigo.upper(),
                    "ficheiro":      f.name,
                    "caminho":       f"{INBOX_FILES}/{codigo}/{f.name}",
                    "ativo":         d["ativo"],
                    "origem":        d["origem"],
                    "tipo":          d["tipo"],
                    "pasta_tipo":    d["pasta_tipo"],
                    "periodo":       d["periodo"],
                    "ano":           d["ano"],
                    "mes":           d["mes"],
                    "periodicidade": d["periodicidade"],
                })
            else:
                rejeitados.append({"pasta": codigo, "ficheiro": f.name, "motivo": motivo_f})

        # Todos os ficheiros de uma submissão têm de ser do mesmo ano
        anos = {v["ano"] for v in validos}
        if len(anos) > 1:
            for v in validos:
                rejeitados.append({"pasta": codigo, "ficheiro": v["ficheiro"],
                                   "motivo": f"anos diferentes na mesma submissão: {sorted(anos)}"})
            validos = []

        trabalho.extend(validos)

    return trabalho, rejeitados, ignoradas

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 7. Execução principal

# CELL ********************

versoes = ler_versoes()
if DRY_RUN:
    versoes = aplicar_simulacao(versoes)

trabalho, rejeitados, ignoradas = construir_lista_trabalho(versoes)

print(f"DRY_RUN={DRY_RUN} | {len(trabalho)} ficheiro(s) a processar | "
      f"{len(rejeitados)} rejeitado(s) | {len(ignoradas)} pasta(s) ignorada(s)")
print()
print("TRABALHO:",   json.dumps(trabalho,   indent=2, default=str))
print("REJEITADOS:", json.dumps(rejeitados, indent=2, default=str))
print("IGNORADAS:",  json.dumps(ignoradas,  indent=2, default=str))

# PRÓXIMOS PASSOS (ainda não implementados):
#   - mover ficheiros válidos para Ano/01-Semi_Structured/Vn/Tipo/
#   - mover rejeitados para 99-Rejected
#   - criar linhas em LOG.Ingest

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 8. Saída para a pipeline

# CELL ********************

resultado = {
    "dry_run": DRY_RUN,
    "trabalho": trabalho,
    "rejeitados": rejeitados,
    "ignoradas": ignoradas,
}
# A pipeline lê este valor (activity output) para alimentar o ForEach.
notebookutils.notebook.exit(json.dumps(resultado, default=str))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
