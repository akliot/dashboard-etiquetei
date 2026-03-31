# Dashboard Etiquetei — Claude Code Reference

## ⚡ Primeira ação (leia antes de qualquer tarefa)

Antes de fazer qualquer alteração, leia silenciosamente:

```bash
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Aprendizados\ Técnicos.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/00\ -\ Visão\ Geral.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Software\ e\ Projetos/Dashboard\ Omie/10\ -\ Lógica\ de\ Negócio.md
```

> **Aprendizados Técnicos.md** é o arquivo central de lições cross-projeto. Leia SEMPRE antes de mudanças de segurança, deploy ou arquitetura.

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
     --set-env-vars GCP_PROJECT_ID=dashboard-koti-omie,BQ_DATASET=etiquetei,DASHBOARD_API_KEY=<KEY_DERIVADA> \
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

## ⚠️ Regras de desenvolvimento — dashboard_bq.html

### Canvas IDs devem ser ÚNICOS
Cada `<canvas id="...">` deve ter um ID globalmente único no HTML inteiro.
Abas diferentes NÃO podem compartilhar canvas IDs. O Chart.js dá erro fatal se tentar reusar um canvas sem destruir o chart anterior.

**Convenção de nomes:** prefixo por aba
- Visão Geral: `spark*` (sparkRecDesp, sparkCaixa...)
- Fluxo de Caixa: `chartFluxo*` (chartFluxoRecDesp, chartFluxoSaldo...)
- Financeiro: `chartFin*` (chartFinStack, chartFinResultado...)
- Receitas: `chartRec*` (chartRecStack, chartRecWaterfall...)
- Projetos: `chartTopProj*`, `chartMargem*`
- Contratos: `chartContratos*` (chartContratosStatus, chartContratosTop...)
- Cobrança: `chartCobranca*`

### renderAll() deve usar try/catch
Cada render de aba deve estar em try/catch para que o erro de uma aba não quebre as outras:
```javascript
try { renderVendas(dc) } catch(e) { console.error('renderVendas', e) }
```

### Sempre destruir chart antes de recriar
```javascript
if (charts.meuChart) { charts.meuChart.destroy(); delete charts.meuChart; }
charts.meuChart = new Chart(...)
```

### Testar TODAS as abas após qualquer mudança
Após modificar o HTML ou JS do dashboard, clicar em cada aba e verificar que renderiza sem erros no console.

## ⚠️ Regras de desenvolvimento — omie_sync_bq.py

### APIs Omie têm page sizes diferentes
- A maioria das APIs aceita `registros_por_pagina: 200`
- **Contratos** (`servicos/contrato`) aceita **máximo 50**
- **Chave da lista de retorno** varia: `contratoCadastro` (não `contratoCadastroArray`)
- Sempre verificar a doc da API: https://developer.omie.com.br/service-list/
- Ao adicionar nova coleta, testar o endpoint isoladamente antes de integrar

### Rate limiting
- A API Omie retorna **403 Forbidden** quando há muitas chamadas em sequência
- Usar `time.sleep(0.1)` entre chamadas paginadas
- Testes locais frequentemente dão 403 — usar GitHub Actions para validar

## Gotchas — Etiquetei-specific

### cat_cod como string (29/03/2026)
Omie retorna `cat_cod` como int para Etiquetei (diferente do Koti que era string).
**Fix:** `str(cat_cod)` forçado no sync. Sempre converter campos de código para `str()` antes de comparar.

### status_codigo int vs string (30/03/2026)
BigQuery retorna `status_codigo` como `INT64` (10), mas `api_bq.py` comparava com `"10"` (string). MRR ficava sempre 0.
**Fix:** `str(r.get("status_codigo", "")) == "10"` no backend + frontend. Mesmo padrão que `cat_cod`.

### dadosFiltrados vs dadosOriginal — contratos (30/03/2026)
`exportarMemoriaComissao()` buscava contratos em `dadosFiltrados.contratos` (não existe — contratos não são filtrados por data).
**Fix:** Usar `dadosOriginal.contratos`. Contratos são dados de referência (cadastro), não transações.

### Filtro de receita SaaS — comissão (30/03/2026)
Comissão cruzava apenas `1.01.02` (Mensalidade). Ignorava Setup (1.01.03), Etiquetas (1.01.99), Locação (1.01.98).
**Fix:** Filtrar por `1.01.*` (todas linhas de receita SaaS). Comissão sobre a receita total do cliente, não só mensalidade.

### Comissões cruzam contratos × lançamentos (30/03/2026)
- Vendedor vem do **contrato** (`nCodVend` → API vendedores)
- Comissão paga vem dos **lançamentos** (cat `2.02.01`, tipo saída)
- Receita dos clientes vem dos **lançamentos** (cat `1.01.*`, tipo entrada)
- Memória de cálculo cruza: receita real × % comissão × pago vs calculado

## Criptografia e Autenticação
- **Login dashboard**: PBKDF2 + SHA-256, salt `etiquetei2026_salt_`, 100.000 iterações
- **API key**: derivada da senha em runtime via PBKDF2, salt `etiquetei2026_api_key_salt`, 100K iter. Nunca hardcoded.
- **Cloud Function**: valida header `X-API-Key` via env var `DASHBOARD_API_KEY`. Sem key → 401.
- **Senha**: NÃO documentar senhas em plaintext neste arquivo.
