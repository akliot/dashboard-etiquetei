# Dashboard Etiquetei — Claude Code Reference

Referência operacional curta para trabalhar no `dashboard-etiquetei`. Contexto histórico detalhado fica no Obsidian e coordenação de tarefas fica em `claude-handoff/`.

## Antes de Alterar

Leia silenciosamente quando a tarefa tocar regra de negócio, segurança, deploy ou arquitetura:

```bash
cat claude-handoff/CURRENT_STATE.md
cat claude-handoff/WORKFLOW.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Aprendizados\ Técnicos.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/00\ -\ Visão\ Geral.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/10\ -\ Lógica\ de\ Negócio.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md
```

Docs por tema, se relevantes: `02 - Pipeline Sync.md`, `03 - Schema BigQuery.md`, `08 - Troubleshooting.md`.

## Projeto

| Item | Valor |
|------|-------|
| GCP | `dashboard-koti-omie` |
| BigQuery | `etiquetei` |
| Dashboard | `https://akliot.github.io/dashboard-etiquetei/dashboard_bq.html` |
| Cloud Function | `api-etiquetei` (`us-central1`) |
| Repo | `https://github.com/akliot/dashboard-etiquetei` |

Arquivos ativos:
- `omie_sync_bq.py`: Omie -> BigQuery, MERGE incremental
- `api_bq.py`: Cloud Function JSON
- `dashboard_bq.html`: SPA do dashboard
- `.github/workflows/sync_omie_bq.yml`: sync 3x/dia

Não criar sem decisão explícita: bot Telegram, `extract_bp_bq.py`, `extract_rh.py`, `dashboard_rh.html`, `dados_*.enc`, `rh_data.*`.

## Deploy

Após alteração, commitar e dar push automaticamente.

- `dashboard_bq.html`: GitHub Pages atualiza no push para `main`
- `api_bq.py`: rodar `bash deploy_api.sh`
- `omie_sync_bq.py`: workflow roda 3x/dia; localmente pode rodar `python3 omie_sync_bq.py`

Deploy manual da API, se necessário:

```bash
gcloud functions deploy api-etiquetei \
  --gen2 --runtime python311 --trigger-http --allow-unauthenticated \
  --entry-point api_dashboard --source . \
  --set-env-vars GCP_PROJECT_ID=dashboard-koti-omie,BQ_DATASET=etiquetei \
  --region us-central1 --memory 512MB --timeout 60s
```

## Dashboard Atual

Abas:
- Visão Geral: KPIs executivos, sparklines, alertas, PDF
- Fluxo de Caixa: caixa, saldo por conta, projeção 90d, waterfalls
- Resultado: DRE Simples, margens, SG&A
- Receitas: SaaS, MRR Bridge, Cohort Retention
- Geografia: choropleth UF, bubble map município, filtro por linha
- Contratos: MRR projetado, tendência, onboarding, vigências, comissões
- Cobrança: inadimplência, aging, top devedores

Período default: `YTD` = últimos 12 meses rolling. Comparativos usam calendário, não deslocamento fixo de dias.

## Regras de Negócio

Receita operacional:

```javascript
// No Etiquetei, 1.01.99 = Venda de Etiquetas. NAO excluir.
const REC_OP_EXCLUIR = new Set([
  '1.04.02','1.04.03','1.04.01','1.02.02',
  '1.03.01','1.03.02','1.03.03','1.03.04','1.03.26'
]);

const DESP_OP_EXCLUIR = new Set(['2.05','2.07','2.08','2.09','2.10','2.11']);
```

DRE Simples Nacional:

```text
Receita Bruta (1.01.*)
(-) DAS (2.06.99)
= Receita Líquida
(-) Custo Direto (2.01)
= Margem Bruta
(-) Comercial (2.02)
(-) Pessoal (2.03)
(-) Admin (2.04)
= EBITDA
(-) Financeiras (2.05)
= Lucro Líquido
```

Fora do DRE: CAPEX (`2.07`), devoluções saída (`2.09`), empréstimos (`2.10`) e não-operacionais (`2.11`). Eles aparecem no caixa, não no resultado operacional.

## Segurança

- Login: PBKDF2/SHA-256, salt `etiquetei2026_salt_`, 100k iterações
- API key: derivada em runtime da senha, salt `etiquetei2026_api_key_salt`
- API valida `X-API-Key` contra `DASHBOARD_API_KEY`
- Nunca documentar senha em plaintext

## Frontend

Chart.js:
- Canvas IDs precisam ser únicos; prefixe por aba (`spark*`, `chartFluxo*`, `chartFin*`, `chartRec*`, `chartGeo*`, `chartContratos*`, `chartCobranca*`)
- Destruir chart antes de recriar:

```javascript
if (charts.meuChart) { charts.meuChart.destroy(); delete charts.meuChart; }
```

Renderização:
- `renderAll()` usa try/catch por aba para uma aba não quebrar as demais
- Dados dinâmicos em HTML precisam de escape (`_esc`) antes de entrar em strings
- Evitar reuso de template literals quando houver CSS/ternário complexo

Validação rápida do JS:

```bash
python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dash.js','w').write('\n'.join(scripts))"
node --check /tmp/dash.js
```

## Pipeline

Omie:
- `cat_cod` pode vir como int; normalizar com `str()`
- `status_codigo` do BigQuery pode vir INT64; comparar com `str(...)`
- Contratos aceitam no máximo `registros_por_pagina=50`
- Rate limit 403: usar `time.sleep(0.1)` entre páginas
- Clientes: cidade pode vir como `"APARECIDA (SP)"`; remover sufixo e manter `cidade_ibge`

BigQuery:
- `CREATE TABLE IF NOT EXISTS` não adiciona coluna em tabela existente
- Para nova coluna, usar `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`

## Gotchas Etiquetei

- `1.01.99` é receita legítima de Venda de Etiquetas
- Sem Faturamento Direto operacional, diferente do Koti
- Contratos são cadastro; usar `dadosOriginal.contratos.lista`
- MRR e churn devem vir de contratos, não de lançamentos
- Status `90` e `99` com `vigencia_fim = 2028-12-31` indicam vigência indefinida/placeholder; não contar como churn de curto prazo
- DAS (`2.06.99`) é imposto operacional no DRE; não há IRPJ separado para Etiquetei
- Comissões cruzam contratos (`nCodVend`) com lançamentos (`2.02.01` e `1.01.*`)

## Status Atual

O status vivo de branches, PRs, specs e proximas tarefas fica em `claude-handoff/CURRENT_STATE.md` e `claude-handoff/BACKLOG.md`.

Nao use esta secao como backlog. Ela existe apenas para apontar para a documentacao de handoff mais atual.
