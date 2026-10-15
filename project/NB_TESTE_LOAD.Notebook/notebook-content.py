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

# PARAMETERS CELL ********************

import json

ITEM_JSON = "{}"

item = json.loads(ITEM_JSON)
print(item["ficheiro"], item["caminho"], item["tabelas"])
notebookutils.notebook.exit(item["ficheiro"])

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
