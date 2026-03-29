# Dashboard Etiquetei — Claude Code Reference

## ⚡ Primeira ação (leia antes de qualquer tarefa)

Antes de fazer qualquer alteração, leia silenciosamente estes arquivos de contexto do Obsidian:

```bash
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/00\ -\ Visão\ Geral.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/10\ -\ Lógica\ de\ Negócio.md
```

Se a tarefa envolver um tema específico, leia também:
- Pipeline/sync → `02 - Pipeline Sync.md`
- BigQuery schema → `03 - Schema BigQuery.md`
- Troubleshooting → `08 - Troubleshooting.md`

Todos em: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Software e Projetos/Dashboard Omie/`

Não pergunte — leia silenciosamente e use o contexto para informar suas decisões.

---

## Informações do projeto

| Item | Valor |
|------|-------|
| Projeto GCP | `dashboard-koti-omie` |
| Dataset BigQuery | `etiquetei` |
| Dashboard URL | `https://akliot.github.io/dashboard-etiquetei/dashboard_bq.html` |
| Cloud Function | `api-etiquetei` (us-central1) |
| Repositório | `https://github.com/akliot/dashboard-etiquetei` |

## Componentes ativos

- `omie_sync_bq.py` — Pipeline: Omie → BigQuery (MERGE incremental)
- `api_bq.py` — Cloud Function que serve JSON pro dashboard
- `dashboard_bq.html` — Frontend financeiro (5 abas)
- `.github/workflows/sync_omie_bq.yml` — CI/CD sync 3x/dia

## Componentes NÃO usados (por enquanto)

- Bot Telegram — não implementado
- extract_bp_bq.py — sem planilha BP/orçamento
- extract_rh.py — sem folha de pagamento
- dashboard_rh.html — sem dashboard RH

## Auto-deploy (NÃO pedir confirmação)

Após qualquer alteração:
1. `git add -A && git commit -m "tipo: descrição" && git push`
2. Se alterou `dashboard_bq.html` → deploy via GitHub Pages (push para main)
3. Se alterou `api_bq.py` → deploy manual:
   ```bash
   gcloud functions deploy api-etiquetei \
     --gen2 --runtime python311 --trigger-http --allow-unauthenticated \
     --entry-point api_dashboard --source . \
     --set-env-vars GCP_PROJECT_ID=dashboard-koti-omie,BQ_DATASET=etiquetei \
     --region us-central1 --memory 512MB --timeout 60s
   ```

NUNCA perguntar "quer commitar?" ou "quer que eu faça push?" — sempre fazer automaticamente.

## Dashboard — Abas

| Aba | Regime | Conteúdo |
|-----|--------|----------|
| Visão Geral | Misto (caixa + competência) | KPIs hero, sparklines, alertas automáticos |
| Fluxo de Caixa | Caixa | KPIs, aging/inadimplência, despesas/receitas |
| Financeiro | Caixa | Contas a pagar/receber, saldos bancários |
| Projetos | Competência | KPIs, scatter margem, barras, tabela detalhada |
| Vendas e Clientes | Caixa | Vendas por mês/etapa, top clientes/projetos |

## Status da implementação (atualizado 29/03/2026)

### ✅ Concluído
- **Repo**: `~/dashboard-etiquetei/` → GitHub `akliot/dashboard-etiquetei` (private)
- **BigQuery**: dataset `etiquetei` — 10 tabelas, 2.542 lançamentos, 233 projetos, 305 clientes
- **`omie_sync_bq.py`**: adaptado (CONTAS_IGNORAR vazio, is_faturamento_direto=False, cat_cod str)
- **`api_bq.py`**: Cloud Function `api-etiquetei` deployada e retornando dados
- **`dashboard_bq.html`**: branding Etiquetei, 5 abas, senha=etiquetei2026
- **GitHub Secrets**: 5/5 configurados (OMIE_APP_KEY/SECRET, GCP_PROJECT_ID, GCP_SA_KEY, BQ_DATASET)
- **GitHub Pages**: ativado em https://akliot.github.io/dashboard-etiquetei/
- **GitHub Actions**: `sync_omie_bq.yml` — sync 3x/dia, primeiro run via Actions com sucesso

### ⏳ Pendente (menor prioridade)
- Identidade visual (cores ainda são do Koti)
- Adaptar `test_pipeline.py` e `test_api.py`

## Arquivos removidos/nunca usados

Não criar:
- `bot_telegram.py`, `Dockerfile`, `cloudbuild.yaml`
- `extract_rh.py`, `extract_bp_bq.py`
- `dashboard_rh.html`
- `dados_*.enc`, `rh_data.*`
