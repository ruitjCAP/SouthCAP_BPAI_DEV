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

# Welcome to your new notebook
# Type here in the cell editor to add code!
import pyodbc

CONN_STR = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=lhxlobjhxx2epmocll5nospfdi-2zdyun3b4poujjzhi63nmpjlnm.database.fabric.microsoft.com,1433;"
    "DATABASE=<your_db_name>;"
    "Authentication=ActiveDirectoryDefault;"
    "Encrypt=yes;"
)

cn = pyodbc.connect(CONN_STR)
print(cn.cursor().execute("SELECT @@VERSION").fetchone()[0])
print(cn.cursor().execute(
    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES "
    "WHERE TABLE_SCHEMA = 'LOG' AND TABLE_NAME = 'Ingest'"
).fetchone()[0], "row(s) found for LOG.Ingest")
cn.close()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
