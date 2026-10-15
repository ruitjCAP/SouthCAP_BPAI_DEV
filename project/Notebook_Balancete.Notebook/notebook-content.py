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

# CELL ********************

from pathlib import Path
import os

# Diretório de origem dos ficheiros
ORIGEM_DIR = Path('/lakehouse/default/Files/2026')

# Configuração SQL Server
SQL_SERVER = 'lhxlobjhxx2epmocll5nospfdi-n4ckehp3ha6ubmm4dfwojvrnxq.database.fabric.microsoft.com,1433'
SQL_DATABASE = 'SouthCapBPAI-a6fb681e-152f-4452-a9b3-988fcdfbc1f3'
SQL_SCHEMA = 'BRZ'
SQL_TABLE = 'Balancete'

# Modo seco (True = não escreve em BD; False = escreve)
DRY_RUN = False

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import pandas as pd
import numpy as np
from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP
import re
import hashlib
import unicodedata
import time
import uuid
import traceback
from difflib import SequenceMatcher
import sqlalchemy as sa
from sqlalchemy import create_engine, text
import pyodbc
import warnings
warnings.filterwarnings('ignore')

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ============================================================================
# LIGAÇÃO SQL SERVER E CONFIGURAÇÃO DE LOGGING
# Todos os passos da execução são registados em SQL_SCHEMA.SQL_LOG_TABLE,
# agrupados pelo mesmo execucao_id. 
# A tabela de logs faz o acompanhamento da execução.
# ============================================================================
import struct
SQL_LOG_TABLE = 'BalanceteLog'



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

# Engine único. Pede um token novo sempre que abre uma ligação nova.
engine = create_engine("mssql+pyodbc://", creator=_connect_fabric)
connection_string = None  # já não é usado: a ligação é feita pelo 'engine' (Entra ID)

EXECUCAO_ID = str(uuid.uuid4())
EXECUCAO_INICIO = time.perf_counter()

def create_table_sql_server(connection_string, sql_statement, dry_run=False):
    """
    Cria tabela no SQL Server (se não existir).
    NÃO faz DROP - preserva dados anteriores.
    """
    try:
        eng = engine
        if dry_run:
            return True
        with eng.connect() as connection:
            connection.execute(text(sql_statement))
            connection.commit()
        return True
    except Exception as e:
        if 'already exists' in str(e) or 'Cannot create' in str(e):
            return True
        print(f"❌ Erro ao criar tabela: {e}")
        return False

SQL_CREATE_LOG_TABLE = f"""
IF OBJECT_ID('{SQL_SCHEMA}.{SQL_LOG_TABLE}', 'U') IS NULL
BEGIN
    CREATE TABLE {SQL_SCHEMA}.{SQL_LOG_TABLE} (
        log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        execucao_id UNIQUEIDENTIFIER NOT NULL,
        data_hora DATETIME2 DEFAULT SYSDATETIME(),
        etapa NVARCHAR(50) NOT NULL,
        status NVARCHAR(20) NOT NULL,
        mensagem NVARCHAR(1000) NOT NULL,
        ficheiro_origem NVARCHAR(255) NULL,
        ativo_codigo NVARCHAR(20) NULL,
        periodo_inicio DATE NULL,
        periodo_fim DATE NULL,
        linhas_afetadas INT NULL,
        num_versao INT NULL,
        duracao_ms INT NULL,
        detalhe_erro NVARCHAR(MAX) NULL,
        dry_run BIT NOT NULL DEFAULT 0
    );

    CREATE INDEX IX_log_execucao ON {SQL_SCHEMA}.{SQL_LOG_TABLE}(execucao_id);
    CREATE INDEX IX_log_data_hora ON {SQL_SCHEMA}.{SQL_LOG_TABLE}(data_hora DESC);
END
"""

log_table_created = create_table_sql_server(connection_string, SQL_CREATE_LOG_TABLE, dry_run=False)

SQL_INSERT_LOG = f"""
INSERT INTO {SQL_SCHEMA}.{SQL_LOG_TABLE}
    (execucao_id, etapa, status, mensagem, ficheiro_origem, ativo_codigo,
     periodo_inicio, periodo_fim, linhas_afetadas, num_versao, duracao_ms,
     detalhe_erro, dry_run)
VALUES
    (:execucao_id, :etapa, :status, :mensagem, :ficheiro_origem, :ativo_codigo,
     :periodo_inicio, :periodo_fim, :linhas_afetadas, :num_versao, :duracao_ms,
     :detalhe_erro, :dry_run)
"""

def log_step(etapa, status, mensagem, ficheiro_origem=None, ativo_codigo=None,
             periodo_inicio=None, periodo_fim=None, linhas_afetadas=None,
             num_versao=None, duracao_ms=None, detalhe_erro=None):
    """
    Regista uma linha na tabela de logs SQL_SCHEMA.SQL_LOG_TABLE.
    Se a gravação falhar (ex: sem ligação à BD), faz fallback para print
    para garantir que a informação não se perde.
    """
    try:
        with engine.connect() as connection:
            connection.execute(text(SQL_INSERT_LOG), {
                'execucao_id': EXECUCAO_ID,
                'etapa': etapa,
                'status': status,
                'mensagem': mensagem,
                'ficheiro_origem': ficheiro_origem,
                'ativo_codigo': ativo_codigo,
                'periodo_inicio': periodo_inicio,
                'periodo_fim': periodo_fim,
                'linhas_afetadas': linhas_afetadas,
                'num_versao': num_versao,
                'duracao_ms': duracao_ms,
                'detalhe_erro': detalhe_erro,
                'dry_run': DRY_RUN
            })
            connection.commit()
    except Exception as e:
        print(f"⚠ [LOG FALLBACK] Falha ao gravar log em {SQL_SCHEMA}.{SQL_LOG_TABLE}: {e}")
        print(f"   [{status}] {etapa}: {mensagem}")

log_step('INICIO_EXECUCAO', 'INFO',
         f"Execução iniciada. ORIGEM_DIR={ORIGEM_DIR} | SQL_SERVER={SQL_SERVER} | "
         f"SQL_DATABASE={SQL_DATABASE} | TABELA={SQL_SCHEMA}.{SQL_TABLE} | DRY_RUN={DRY_RUN}")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


def normalize_text(value):
    """
    Normaliza texto: remove espaços extra, trata NaN/None, remove non-breaking spaces
    """
    if pd.isna(value) or value is None:
        return ""
    s = str(value).strip()
    s = s.replace('\xa0', ' ')  # non-breaking space
    s = re.sub(r'\s+', ' ', s)  # normaliza espaços múltiplos
    return s

def _strip_accents(value):
    """
    Remove acentos de um texto (ex: 'Marquês' -> 'Marques'), para permitir
    comparações robustas independentemente de acentuação.
    """
    return ''.join(c for c in unicodedata.normalize('NFKD', value) if not unicodedata.combining(c))

# Mapa de nomes de entidade conhecidos -> ativo_codigo.
# Chave: lista de palavras/expressões-chave (sem acentos, procuradas com fronteira de palavra).
# Verificado ANTES da lógica genérica de iniciais.
ATIVO_CODIGO_KNOWN_MAP = [
    (['TORRE OCIDENTE'], 'TOC'),
    (['CITY MARQUES'], 'CIM'),
    (['EIFCITYLIS'], 'EIF'),
    (['MAXIRENT'], 'MXR'),
    (['NOS'], 'NOS'),
    (['OPE', 'OFFICE PARK EXPO'], 'OPE'),
    (['SUMMERCITY'], 'SC'),
    (['TORRES DE LISBOA', 'TORDELIS'], 'TDL'),
]

def match_known_ativo_codigo(entity_name):
    """
    Procura por nomes de entidade conhecidos (lista fixa) e devolve o
    ativo_codigo correspondente. Devolve None se não houver correspondência,
    para que a lógica genérica de extração possa ser usada como fallback.
    """
    entity_norm = _strip_accents(normalize_text(entity_name)).upper()

    for keywords, codigo in ATIVO_CODIGO_KNOWN_MAP:
        for keyword in keywords:
            if re.search(r'\b' + re.escape(keyword) + r'\b', entity_norm):
                return codigo

    return None

def fuzzy_match(text, candidates, threshold=0.7):
    """
    Fuzzy matching usando SequenceMatcher.
    Retorna (best_match, score)
    """
    text_norm = normalize_text(text).lower()
    best_match = None
    best_score = 0
    
    for candidate in candidates:
        candidate_norm = normalize_text(candidate).lower()
        score = SequenceMatcher(None, text_norm, candidate_norm).ratio()
        if score > best_score:
            best_score = score
            best_match = candidate
    
    return best_match, best_score

def money_to_decimal(value):
    """
    Converte valor monetário para Decimal(19,2)
    Suporta: str, float, Decimal, int, NaN
    """
    if pd.isna(value):
        return Decimal('0.00')
    
    try:
        if isinstance(value, Decimal):
            d = value
        elif isinstance(value, str):
            clean = value.replace('.', '').replace(',', '.').strip()
            d = Decimal(clean)
        else:
            d = Decimal(str(float(value)))
        
        # Arredondar para 2 casas decimais com ROUND_HALF_UP
        return d.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
    except Exception:
        return Decimal('0.00')

def parse_periodo_balancete(periodo_text):
    """
    Extrai período de texto como "Periodo : 01-05-2026 (5) a 31-05-2026 (5)"
    Retorna (data_inicio, data_fim, periodo_text_cleaned)
    """
    texto = normalize_text(periodo_text)
    
    # Regex para capturar as duas datas (DD-MM-YYYY)
    pattern = r'(\d{1,2})-(\d{1,2})-(\d{4}).*?a\s+(\d{1,2})-(\d{1,2})-(\d{4})'
    match = re.search(pattern, texto)
    
    if match:
        d1, m1, y1, d2, m2, y2 = match.groups()
        try:
            data_inicio = datetime(int(y1), int(m1), int(d1)).date()
            data_fim = datetime(int(y2), int(m2), int(d2)).date()
            return data_inicio, data_fim, f"{data_inicio} a {data_fim}"
        except ValueError:
            return None, None, None
    
    return None, None, None

def extract_ativo_codigo_from_entity(entity_name):

    # 1. Verificar primeiro se o nome corresponde a um ativo conhecido
    codigo_conhecido = match_known_ativo_codigo(entity_name)
    if codigo_conhecido:
        return codigo_conhecido

    # 2. Lógica genérica (fallback) - apenas quando não há correspondência conhecida
    entity_clean = normalize_text(entity_name)
    
    # Se contiver " - ", retem a parte antes
    if ' - ' in entity_clean:
        entity_clean = entity_clean.split(' - ')[0]
    
    # Se contiver ",", retem a parte antes
    if ',' in entity_clean:
        entity_clean = entity_clean.split(',')[0]
    
    # Extrair as iniciais das palavras (maiúsculas)
    words = entity_clean.split()
    initials = ''.join([w[0].upper() for w in words if w])

    return initials[:10]  # máximo 10 caracteres

def make_hash(row):
    """
    Cria SHA256 de valores da linha para deduplicação.
    Concatena todos os valores com "|"
    """
    values = [str(v) for v in row]
    combined = '|'.join(values)
    return hashlib.sha256(combined.encode()).hexdigest()

def find_periodo_in_sheet(df_raw):
    """
    Procura dinamicamente o período em qualquer posição do ficheiro.
    Procura pela palavra-chave "Periodo" e extrai o texto de data.
    Retorna (data_inicio, data_fim, periodo_display, linha_encontrada, coluna_encontrada)
    """
    # Procurar "Periodo" em todas as células
    for row_idx in range(min(10, len(df_raw))):  # Procurar nas primeiras 10 linhas
        for col_idx in range(len(df_raw.columns)):
            cell_val = normalize_text(df_raw.iloc[row_idx, col_idx]).lower()
            
            # Se encontrar "periodo", procurar datas na mesma linha ou linhas próximas
            if 'periodo' in cell_val or 'period' in cell_val:
                # Procurar datas na mesma linha (colunas à direita)
                for check_col in range(col_idx, min(col_idx + 5, len(df_raw.columns))):
                    check_val = normalize_text(df_raw.iloc[row_idx, check_col])
                    data_inicio, data_fim, periodo_display = parse_periodo_balancete(check_val)
                    
                    if data_inicio and data_fim:
                        return data_inicio, data_fim, periodo_display, row_idx, check_col
                
                # Se não encontrou na linha, procurar na coluna abaixo
                for check_row in range(row_idx + 1, min(row_idx + 5, len(df_raw))):
                    check_val = normalize_text(df_raw.iloc[check_row, col_idx])
                    data_inicio, data_fim, periodo_display = parse_periodo_balancete(check_val)
                    
                    if data_inicio and data_fim:
                        return data_inicio, data_fim, periodo_display, check_row, col_idx
    
    return None, None, None, None, None

def find_entity_name_in_sheet(df_raw):
    """
    Procura dinamicamente o nome da entidade (ativo).
    Procura por padrões:
    1. Palavras-chave como "Empresa", "Ativo"
    2. Nomes com " - " (padrão comum para nomes de empresas)
    3. Nomes com "S.A." ou "LDA" (indicadores de entidades)
    Retorna (entity_name, linha_encontrada, coluna_encontrada)
    """
    # Procurar "Empresa" ou similares nas primeiras linhas
    for row_idx in range(min(5, len(df_raw))):
        for col_idx in range(min(3, len(df_raw.columns))):
            cell_val = normalize_text(df_raw.iloc[row_idx, col_idx]).lower()
            
            if any(kw in cell_val for kw in ['empresa', 'ativo', 'entity', 'entidade']):
                # Procurar o valor na próxima coluna ou linha
                if col_idx + 1 < len(df_raw.columns):
                    entity_name = normalize_text(df_raw.iloc[row_idx, col_idx + 1])
                    if entity_name and entity_name.upper() not in ['', 'NAN']:
                        return entity_name, row_idx, col_idx + 1
                
                # Ou na linha abaixo, mesma coluna
                if row_idx + 1 < len(df_raw):
                    entity_name = normalize_text(df_raw.iloc[row_idx + 1, col_idx])
                    if entity_name and entity_name.upper() not in ['', 'NAN']:
                        return entity_name, row_idx + 1, col_idx
    
    # Fallback: procurar nomes com características de empresa (contém " - " ou termina com S.A., LDA, etc)
    for row_idx in range(min(5, len(df_raw))):
        for col_idx in range(len(df_raw.columns)):
            entity_name = normalize_text(df_raw.iloc[row_idx, col_idx])
            
            # Critério: nome com " - " ou com terminações típicas de empresas
            if entity_name and len(entity_name) > 5:
                if (' - ' in entity_name and any(term in entity_name.upper() for term in [' S.A.', ' LDA', ' SARL', ' LTDA', ' SA', ' LTDA.'])) or \
                   entity_name.upper().endswith(('S.A.', 'LDA', 'SARL', 'LTDA', 'SA', 'LTDA.')):
                    return entity_name, row_idx, col_idx
    
    # Último fallback: procurar nome na primeira coluna não-vazia (linhas 0-4)
    # Nota: limite de comprimento reduzido para 1 para apanhar códigos curtos
    # (ex: "OPE") que aparecem sozinhos, sem nome completo da entidade.
    for row_idx in range(min(5, len(df_raw))):
        for col_idx in range(min(3, len(df_raw.columns))):
            entity_name = normalize_text(df_raw.iloc[row_idx, col_idx])
            if entity_name and len(entity_name) > 1 and entity_name.upper() not in ['CONTA', 'DESIGNAÇÃO', 'DESIGNACAO', 'NAN']:
                # Se não estiver vazio e não for um cabeçalho conhecida
                if not any(header in entity_name.upper() for header in ['CONTA', 'DESIGNAÇÃO', 'BALANCETE', 'MOV.', 'SALDO']):
                    return entity_name, row_idx, col_idx
    
    return "", None, None


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 3. Função de Extração: read_balancete

# CELL ********************

def read_balancete(file_path):
    inicio = time.perf_counter()

    df_raw = pd.read_excel(file_path, sheet_name=0, header=None)

    # Procura dinâmica do período (robusta contra deslocações)
    periodo_inicio, periodo_fim, periodo_display, periodo_row, periodo_col = find_periodo_in_sheet(df_raw)

    if not periodo_inicio or not periodo_fim:
        log_step('EXTRACAO_PERIODO', 'ERRO',
                 "Não consegui extrair o período de nenhuma célula do ficheiro",
                 ficheiro_origem=file_path.name)
        raise ValueError(f"Não consegui extrair o período de nenhuma célula do ficheiro")

    log_step('EXTRACAO_PERIODO', 'SUCESSO', f"Período encontrado: {periodo_display}",
             ficheiro_origem=file_path.name, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim)

    # Procura dinâmica do nome da entidade (robusta contra deslocações)
    entity_name, entity_row, entity_col = find_entity_name_in_sheet(df_raw)
    ativo_codigo = extract_ativo_codigo_from_entity(entity_name)

    if not ativo_codigo or ativo_codigo == "":
        # Fallback: usar "DESCONHECIDO" se não conseguir extrair
        ativo_codigo = "DESCONHECIDO"
        log_step('EXTRACAO_ATIVO', 'AVISO',
                 f"Não consegui extrair ativo de '{entity_name}' - a usar 'DESCONHECIDO'",
                 ficheiro_origem=file_path.name, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim)
    else:
        log_step('EXTRACAO_ATIVO', 'SUCESSO',
                 f"Ativo código: {ativo_codigo} (de '{entity_name[:100]}')",
                 ficheiro_origem=file_path.name, ativo_codigo=ativo_codigo,
                 periodo_inicio=periodo_inicio, periodo_fim=periodo_fim)

    header_row_idx = None
    col_indices = {}
    conta_col_idx = None

    # Procurar "Conta" em qualquer coluna (robustez contra deslocações horizontais)
    for idx in range(3, 20):  # Linhas 3-20 (índices 3-19)
        if idx >= len(df_raw):
            break
        
        # Procurar em todas as colunas desta linha
        for col in range(min(10, len(df_raw.columns))):
            cell_val = normalize_text(df_raw.iloc[idx, col])
            if cell_val.lower() == 'conta' or fuzzy_match(cell_val, ['Conta'], threshold=0.85)[1] >= 0.85:
                header_row_idx = idx
                conta_col_idx = col
                break
        
        if header_row_idx is not None:
            break
    
    if header_row_idx is None:
        log_step('EXTRACAO_CABECALHO', 'ERRO',
                 "Não consegui encontrar a linha de cabeçalho (esperado 'Conta')",
                 ficheiro_origem=file_path.name, ativo_codigo=ativo_codigo,
                 periodo_inicio=periodo_inicio, periodo_fim=periodo_fim)
        raise ValueError("Não consegui encontrar a linha de cabeçalho (esperado 'Conta')")

    log_step('EXTRACAO_CABECALHO', 'SUCESSO',
             f"Cabeçalho encontrado na linha {header_row_idx + 1}, coluna {conta_col_idx}",
             ficheiro_origem=file_path.name, ativo_codigo=ativo_codigo,
             periodo_inicio=periodo_inicio, periodo_fim=periodo_fim)

    col_names = ['conta', 'designacao', 'debito_periodo', 'credito_periodo', 'saldo_periodo',
                 'debito_acumulado', 'credito_acumulado', 'saldo_acumulado']
    
    # Mapear índices das colunas em relação ao "Conta"
    for i, col_name in enumerate(col_names):
        col_indices[col_name] = conta_col_idx + i
    
    data_start = header_row_idx + 2  # Começar após as linhas de cabeçalho
    records = []
    total_rows_skipped = 0
    
    for idx in range(data_start, len(df_raw)):
        # Coluna "Conta" (agora relativa ao índice encontrado)
        c0 = df_raw.iloc[idx, col_indices['conta']]
        
        # Se coluna "Conta" vazia, pular
        if pd.isna(c0):
            total_rows_skipped += 1
            continue
        
        c0_str = normalize_text(c0)
        
        # Ignorar linhas de totais
        if any(kw in c0_str.lower() for kw in ['total', 'totais', 'pág.', 'page']):
            total_rows_skipped += 1
            continue
        
        # Extrair valores
        try:
            conta = c0_str
            designacao = normalize_text(df_raw.iloc[idx, col_indices['designacao']])
            debito_periodo = money_to_decimal(df_raw.iloc[idx, col_indices['debito_periodo']])
            credito_periodo = money_to_decimal(df_raw.iloc[idx, col_indices['credito_periodo']])
            saldo_periodo = money_to_decimal(df_raw.iloc[idx, col_indices['saldo_periodo']])
            debito_acumulado = money_to_decimal(df_raw.iloc[idx, col_indices['debito_acumulado']])
            credito_acumulado = money_to_decimal(df_raw.iloc[idx, col_indices['credito_acumulado']])
            saldo_acumulado = money_to_decimal(df_raw.iloc[idx, col_indices['saldo_acumulado']])
            
            # Validação mínima: se conta e designacao vazios, pular
            if not conta and not designacao:
                total_rows_skipped += 1
                continue
            
            # Criar linha de dados
            hash_linha = make_hash([
                ativo_codigo, periodo_inicio, periodo_fim, conta, designacao,
                debito_periodo, credito_periodo, saldo_periodo,
                debito_acumulado, credito_acumulado, saldo_acumulado
            ])
            
            record = {
                'ativo_codigo': ativo_codigo,
                'periodo_inicio': periodo_inicio,
                'periodo_fim': periodo_fim,
                'conta': conta,
                'designacao': designacao,
                'debito_periodo_eur': debito_periodo,
                'credito_periodo_eur': credito_periodo,
                'saldo_periodo_eur': saldo_periodo,
                'debito_acumulado_eur': debito_acumulado,
                'credito_acumulado_eur': credito_acumulado,
                'saldo_acumulado_eur': saldo_acumulado,
                'ficheiro_origem': file_path.name,
                'linha_origem': idx + 1,  # 1-indexed para Excel
                'hash_linha': hash_linha
            }
            
            records.append(record)
        
        except Exception:
            total_rows_skipped += 1
            continue
    
    duracao_ms = int((time.perf_counter() - inicio) * 1000)

    log_step('EXTRACAO_LINHAS', 'SUCESSO' if records else 'AVISO',
             f"{len(records)} linhas transformadas, {total_rows_skipped} linhas ignoradas",
             ficheiro_origem=file_path.name, ativo_codigo=ativo_codigo,
             periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
             linhas_afetadas=len(records), duracao_ms=duracao_ms)

    return pd.DataFrame(records) if records else pd.DataFrame()


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ============================================================================
# CONFIGURAÇÃO: Qual ficheiro de Balancete usar?
# ============================================================================

ficheiro_pattern = '*balancete*.xls* (sem distinção de maiúsculas)'
ficheiros = [
    f for f in ORIGEM_DIR.iterdir()
    if f.is_file()
    and 'balancete' in f.name.lower()
    and f.suffix.lower() in ('.xls', '.xlsx', '.xlsm')
    and not f.name.startswith('~$')
]

if not ficheiros:
    log_step('SELECAO_FICHEIRO', 'ERRO',
             f"Nenhum ficheiro encontrado com o padrão '{ficheiro_pattern}' em {ORIGEM_DIR}")
    ficheiro = None
    df_balancete = pd.DataFrame()
    load_ok = False
else:
    # ========================================================================
    # CRITÉRIO DE SELEÇÃO - ALTERE CONFORME NECESSÁRIO
    # ========================================================================
    # Opção 1: Usar o MAIS RECENTE (por data de modificação)
    CRITERIO_SELECCAO = "mais_recente"  # ← ALTERE AQUI se desejar outra opção

    # Outras opções disponíveis:
    # CRITERIO_SELECCAO = "primeiro"        # Usa o primeiro alfabeticamente
    # CRITERIO_SELECCAO = "manual:0"        # Escolhe manualmente pelo índice (0=primeiro)
    # ========================================================================

    if CRITERIO_SELECCAO == "mais_recente":
        # Ordenar por data de modificação (mais recente primeiro)
        ficheiros_sorted = sorted(ficheiros, key=lambda f: f.stat().st_mtime, reverse=True)
        ficheiro = ficheiros_sorted[0]

    elif CRITERIO_SELECCAO == "primeiro":
        # Usar o primeiro alfabeticamente
        ficheiro = sorted(ficheiros)[0]

    elif CRITERIO_SELECCAO.startswith("manual:"):
        # Escolher manualmente por índice
        idx_manual = int(CRITERIO_SELECCAO.split(":")[1])
        ficheiro_sorted = sorted(ficheiros)
        if 0 <= idx_manual < len(ficheiro_sorted):
            ficheiro = ficheiro_sorted[idx_manual]
        else:
            ficheiro = sorted(ficheiros)[0]

    else:
        # Fallback: usar primeiro
        ficheiro = sorted(ficheiros)[0]

    log_step('SELECAO_FICHEIRO', 'SUCESSO',
             f"{len(ficheiros)} ficheiro(s) encontrado(s): {', '.join(f.name for f in ficheiros)}. "
             f"Critério: {CRITERIO_SELECCAO}. Selecionado: {ficheiro.name}",
             ficheiro_origem=ficheiro.name)

    # Carregar dados
    df_balancete = read_balancete(ficheiro)

    if len(df_balancete) > 0:
        load_ok = True
    else:
        log_step('EXTRACAO', 'ERRO', f"Nenhuma linha de dados extraída de '{ficheiro.name}'",
                 ficheiro_origem=ficheiro.name)
        load_ok = False


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

def validate_balancete_df(df):
    """
    Validações pré-carga:
    1. Colunas obrigatórias não-nulas
    2. Hash único (não duplicatas)
    3. Valores monetários válidos
    """
    errors = []

    # 1. Colunas obrigatórias
    required_cols = ['ativo_codigo', 'periodo_inicio', 'periodo_fim', 'conta', 
                    'designacao', 'hash_linha']
    
    for col in required_cols:
        nulls = df[col].isna().sum()
        if nulls > 0:
            errors.append(f"{col}: {nulls} valores nulos")
    
    # 2. Hash único
    duplicates = df['hash_linha'].duplicated().sum()
    if duplicates > 0:
        errors.append(f"hash_linha: {duplicates} duplicatas detectadas")
    
    # 3. Valores monetários
    money_cols = ['debito_periodo_eur', 'credito_periodo_eur', 'saldo_periodo_eur',
                  'debito_acumulado_eur', 'credito_acumulado_eur', 'saldo_acumulado_eur']
    
    for col in money_cols:
        if not all(isinstance(v, Decimal) for v in df[col]):
            errors.append(f"{col}: tipo não é Decimal")

    ativo_codigo = df['ativo_codigo'].iloc[0]
    periodo_inicio = df['periodo_inicio'].iloc[0]
    periodo_fim = df['periodo_fim'].iloc[0]

    if errors:
        log_step('VALIDACAO', 'ERRO', "; ".join(errors),
                 ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                 linhas_afetadas=len(df))
        return False
    else:
        log_step('VALIDACAO', 'SUCESSO',
                 f"Validações OK - {len(df)} linhas prontas para carga",
                 ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                 linhas_afetadas=len(df))
        return True

# Executar validações
if not df_balancete.empty:
    validations_ok = validate_balancete_df(df_balancete)
else:
    log_step('VALIDACAO', 'AVISO', "DataFrame vazio - não é possível validar")
    validations_ok = False


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# SQL para criar tabela Balancete COM VERSIONAMENTO
SQL_CREATE_TABLE = f"""
-- APENAS criar se não existir (não fazer DROP!)
IF OBJECT_ID('{SQL_SCHEMA}.{SQL_TABLE}', 'U') IS NULL
BEGIN
    CREATE TABLE {SQL_SCHEMA}.{SQL_TABLE} (
        balancete_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        ativo_codigo NVARCHAR(20) NOT NULL,
        periodo_inicio DATE NOT NULL,
        periodo_fim DATE NOT NULL,
        conta NVARCHAR(30) NOT NULL,
        designacao NVARCHAR(500),
        debito_periodo_eur DECIMAL(19,2),
        credito_periodo_eur DECIMAL(19,2),
        saldo_periodo_eur DECIMAL(19,2),
        debito_acumulado_eur DECIMAL(19,2),
        credito_acumulado_eur DECIMAL(19,2),
        saldo_acumulado_eur DECIMAL(19,2),
        ficheiro_origem NVARCHAR(255),
        linha_origem INT,
        hash_linha CHAR(64),
        data_carga DATETIME2 DEFAULT SYSDATETIME(),

        -- VERSIONAMENTO
        data_versao DATETIME2 DEFAULT SYSDATETIME(),
        num_versao INT NOT NULL DEFAULT 1,

        CONSTRAINT IX_balancete_composite_1 CHECK (periodo_inicio <= periodo_fim)
    );

    -- Índices para performance
    CREATE INDEX IX_balancete_ativo_periodo ON {SQL_SCHEMA}.{SQL_TABLE}(ativo_codigo, periodo_inicio, periodo_fim);
    CREATE INDEX IX_balancete_conta ON {SQL_SCHEMA}.{SQL_TABLE}(conta);
    CREATE INDEX IX_balancete_carga ON {SQL_SCHEMA}.{SQL_TABLE}(data_carga DESC);
    CREATE INDEX IX_balancete_num_versao ON {SQL_SCHEMA}.{SQL_TABLE}(ativo_codigo, periodo_inicio, periodo_fim, num_versao DESC);
END
"""


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Criar tabela (ou verificar se existe)
table_created = create_table_sql_server(connection_string, SQL_CREATE_TABLE, dry_run=DRY_RUN)

log_step('CRIACAO_TABELA', 'SUCESSO' if table_created else 'ERRO',
         f"Tabela {SQL_SCHEMA}.{SQL_TABLE} " +
         ("criada/verificada com sucesso (dados anteriores preservados)" if table_created
          else "não pôde ser criada/verificada"))


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

def load_to_sql_server(df, connection_string, schema, table, dry_run=False):
    """
    Carregamento com versionamento simples:
    - Se o ficheiro carregado tiver exatamente o mesmo conteúdo (mesmos hash_linha)
      da última versão já guardada, NÃO é criada uma nova versão - a tabela fica inalterada
    - Caso contrário, insere TODAS as linhas do novo ficheiro com um num_versao mais recente
      (MAX(num_versao) + 1 para a mesma combinação ativo_codigo/periodo_inicio/periodo_fim)
    - Mantém histórico de todas as versões carregadas para auditoria
    """
    if df.empty:
        log_step('CARGA_DADOS', 'AVISO', "DataFrame vazio - nada para carregar")
        return False

    ativo_codigo = df['ativo_codigo'].iloc[0]
    periodo_inicio = df['periodo_inicio'].iloc[0]
    periodo_fim = df['periodo_fim'].iloc[0]

    if dry_run:
        log_step('CARGA_DADOS', 'INFO',
                 f"[DRY_RUN] Carga não executada. {len(df)} linhas seriam carregadas",
                 ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                 linhas_afetadas=len(df))
        return True

    inicio = time.perf_counter()

    try:
        engine_local = engine

        # ============================================================
        # PASSO 1: Verificar se a última versão tem exatamente o mesmo conteúdo
        # ============================================================
        sql_ultima_versao = f"""
        SELECT hash_linha, num_versao
        FROM [{schema}].[{table}]
        WHERE ativo_codigo = :ativo_codigo
            AND periodo_inicio = :periodo_inicio
            AND periodo_fim = :periodo_fim
            AND num_versao = (
                SELECT MAX(num_versao)
                FROM [{schema}].[{table}]
                WHERE ativo_codigo = :ativo_codigo
                    AND periodo_inicio = :periodo_inicio
                    AND periodo_fim = :periodo_fim
            )
        """

        with engine_local.connect() as connection:
            result = connection.execute(text(sql_ultima_versao), {
                'ativo_codigo': ativo_codigo,
                'periodo_inicio': periodo_inicio,
                'periodo_fim': periodo_fim
            })
            rows_ultima_versao = result.fetchall()

        if rows_ultima_versao:
            num_versao_atual = rows_ultima_versao[0][1]
            hashes_atuais = sorted(row[0] for row in rows_ultima_versao)
            hashes_novos = sorted(df['hash_linha'])

            if hashes_atuais == hashes_novos:
                log_step('CARGA_DADOS', 'SUCESSO',
                         f"Ficheiro sem alterações em relação à versão {num_versao_atual} - nenhuma nova versão criada",
                         ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                         num_versao=num_versao_atual, linhas_afetadas=0,
                         duracao_ms=int((time.perf_counter() - inicio) * 1000))
                return True

            num_versao = num_versao_atual + 1
        else:
            num_versao = 1

        # ============================================================
        # PASSO 2: Inserir todas as linhas com a nova versão
        # ============================================================
        df_insert = df.copy()
        df_insert['data_versao'] = datetime.now()
        df_insert['num_versao'] = num_versao

        # Converter Decimal para float
        money_cols = ['debito_periodo_eur', 'credito_periodo_eur', 'saldo_periodo_eur',
                      'debito_acumulado_eur', 'credito_acumulado_eur', 'saldo_acumulado_eur']
        for col in money_cols:
            if col in df_insert.columns:
                df_insert[col] = df_insert[col].apply(lambda x: float(x) if x is not None else None)

        try:
            df_insert.to_sql(table, con=engine_local, schema=schema, if_exists="append", index=False, chunksize=100)
            inserted = len(df_insert)
        except Exception as insert_error:
            log_step('CARGA_DADOS', 'ERRO', f"Erro ao inserir dados: {insert_error}",
                     ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                     num_versao=num_versao, detalhe_erro=traceback.format_exc())
            return False

        log_step('CARGA_DADOS', 'SUCESSO',
                 f"{inserted} linhas inseridas com num_versao={num_versao}",
                 ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                 linhas_afetadas=inserted, num_versao=num_versao,
                 duracao_ms=int((time.perf_counter() - inicio) * 1000))
        return True

    except Exception as e:
        log_step('CARGA_DADOS', 'ERRO', f"Erro ao carregar dados: {e}",
                 ativo_codigo=ativo_codigo, periodo_inicio=periodo_inicio, periodo_fim=periodo_fim,
                 detalhe_erro=traceback.format_exc())
        return False

# Carregar dados
if not df_balancete.empty and validations_ok:
    load_ok = load_to_sql_server(df_balancete, connection_string, SQL_SCHEMA, SQL_TABLE, dry_run=DRY_RUN)
else:
    log_step('CARGA_DADOS', 'AVISO', "Não foi possível carregar - validações falharam ou DataFrame vazio")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Query de validação pós-carga COM VERSIONAMENTO
SQL_VALIDATION = f"""
SELECT
    ativo_codigo,
    periodo_inicio,
    periodo_fim,
    num_versao,
    COUNT(*) as num_contas,
    SUM(debito_periodo_eur) as total_debito_periodo,
    SUM(credito_periodo_eur) as total_credito_periodo,
    SUM(saldo_periodo_eur) as total_saldo_periodo,
    MIN(data_versao) as data_versao_primeira,
    MAX(data_versao) as data_versao_ultima
FROM {SQL_SCHEMA}.{SQL_TABLE}
GROUP BY ativo_codigo, periodo_inicio, periodo_fim, num_versao
ORDER BY ativo_codigo, periodo_inicio, periodo_fim, num_versao DESC;
"""

# Query de auditoria - histórico completo de carregamentos
SQL_AUDITORIA = f"""
SELECT
    ativo_codigo,
    periodo_inicio,
    periodo_fim,
    num_versao,
    COUNT(DISTINCT hash_linha) as num_linhas,
    MIN(data_versao) as data_carga,
    MAX(data_versao) as ultima_atualizacao
FROM {SQL_SCHEMA}.{SQL_TABLE}
GROUP BY ativo_codigo, periodo_inicio, periodo_fim, num_versao
ORDER BY ativo_codigo, periodo_inicio, periodo_fim, num_versao DESC;
"""


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Executar queries de validação e auditoria
def run_validation_query(query, title="Validação", dry_run=False):
    """
    Executa query de validação/auditoria pós-carga
    """
    if dry_run:
        return False

    try:
        with engine.connect() as connection:
            result = connection.execute(text(query))
            rows = result.fetchall()

        if rows:
            log_step('VALIDACAO_POS_CARGA', 'SUCESSO', f"{title}: {len(rows)} linha(s) obtida(s)")
            return True
        else:
            log_step('VALIDACAO_POS_CARGA', 'AVISO', f"{title}: nenhum dado encontrado na tabela")
            return False

    except Exception as e:
        log_step('VALIDACAO_POS_CARGA', 'ERRO', f"Erro ao executar {title}: {e}",
                 detalhe_erro=traceback.format_exc())
        return False

# Executar validações
if not DRY_RUN:
    # Query de validação (dados por ativo/período/versão)
    run_validation_query(SQL_VALIDATION, title="Dados por Ativo/Período/Versão", dry_run=DRY_RUN)

    # Query de auditoria (histórico de versões)
    run_validation_query(SQL_AUDITORIA, title="Auditoria - Histórico de Versões", dry_run=DRY_RUN)
else:
    log_step('VALIDACAO_POS_CARGA', 'INFO', "[DRY_RUN] Validações pós-carga não executadas")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

duracao_total_ms = int((time.perf_counter() - EXECUCAO_INICIO) * 1000)

status_final = 'SUCESSO' if (validations_ok and load_ok) else 'ERRO'

log_step('RESUMO_FINAL', status_final,
         f"Ficheiro={ficheiro.name if ficheiros else 'N/A'} | "
         f"Ativo={df_balancete['ativo_codigo'].iloc[0] if not df_balancete.empty else 'N/A'} | "
         f"Validação={'OK' if validations_ok else 'ERRO'} | "
         f"Tabela={'OK' if table_created else 'ERRO'} | "
         f"Carga={'OK' if load_ok else 'ERRO'}",
         ficheiro_origem=ficheiro.name if ficheiros else None,
         ativo_codigo=df_balancete['ativo_codigo'].iloc[0] if not df_balancete.empty else None,
         periodo_inicio=df_balancete['periodo_inicio'].iloc[0] if not df_balancete.empty else None,
         periodo_fim=df_balancete['periodo_fim'].iloc[0] if not df_balancete.empty else None,
         linhas_afetadas=len(df_balancete) if not df_balancete.empty else 0,
         duracao_ms=duracao_total_ms)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# ============================================================================
# 🚨 LIMPEZA DE DADOS (Opcional)
# ============================================================================
# Descomente a linha abaixo se quiser APAGAR TUDO e começar do zero
# (Isto vai dropar a tabela, perder todo o histórico, e recriá-la vazia)

# print("\n🔄 APAGANDO tabela para começar do zero...\n")
# engine = create_engine(connection_string)
# with engine.connect() as connection:
#     connection.execute(text(f"DROP TABLE IF EXISTS {SQL_SCHEMA}.{SQL_TABLE}"))
#     connection.commit()
# print("✅ Tabela apagada! Agora execute a célula de criar tabela.")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from datetime import datetime
import pandas as pd

print("Pasta existe:", ORIGEM_DIR.exists())

ficheiros = list(ORIGEM_DIR.glob('*BALANCETE*.xls*'))
print("Ficheiros encontrados:", len(ficheiros))
for f in ficheiros:
    print(" -", f.name, "|", f.suffix, "|", datetime.fromtimestamp(f.stat().st_mtime))

df_raw = pd.read_excel(ficheiros[0], sheet_name=0, header=None)
print("Dimensões:", df_raw.shape)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import struct
import pyodbc

SERVER = "lhxlobjhxx2epmocll5nospfdi-n4ckehp3ha6ubmm4dfwojvrnxq.database.fabric.microsoft.com,1433"      # inclui o ,1433 se vier
DATABASE = "SouthCapBPAI-a6fb681e-152f-4452-a9b3-988fcdfbc1f3"  # nome completo, com sufixo

# Token de acesso (identidade do utilizador que corre o notebook)
token = notebookutils.credentials.getToken("https://database.windows.net/").encode("UTF-16-LE")
token_struct = struct.pack(f"<I{len(token)}s", len(token), token)

conn_str = (
    "Driver={ODBC Driver 18 for SQL Server};"
    f"Server={SERVER};"
    f"Database={DATABASE};"
    "Encrypt=yes;TrustServerCertificate=no;"
)

conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cur = conn.cursor()

cur.execute("SELECT DB_NAME()")
print("Ligado à BD:", cur.fetchone()[0])

cur.execute("SELECT name FROM sys.schemas WHERE name = 'BRZ'")
print("Schema BRZ existe:", cur.fetchone() is not None)

conn.close()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

with engine.connect() as c:
    print(c.execute(text("SELECT name FROM sys.schemas WHERE name = 'BRZ'")).fetchall())
    print(c.execute(text("SELECT etapa, status FROM BRZ.BalanceteLog")).fetchall())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

with engine.connect() as c:
    rows = c.execute(text("""
        SELECT etapa, status, linhas_afetadas, LEFT(mensagem, 150)
        FROM BRZ.BalanceteLog
        WHERE execucao_id = :id
        ORDER BY log_id
    """), {"id": EXECUCAO_ID}).fetchall()
for r in rows:
    print(r)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
