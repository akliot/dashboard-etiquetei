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
- `dashboard_bq.html` — Frontend financeiro (7 abas)
- `.github/workflows/sync_omie_bq.yml` — CI/CD sync 3x/dia

## Componentes NÃO usados

- Bot Telegram — não implementado (decisão: manter fora por ora)
- `extract_bp_bq.py` — sem planilha BP/orçamento
- `extract_rh.py` — sem folha de pagamento
- `dashboard_rh.html` — sem dashboard RH

## Auto-deploy (NÃO pedir confirmação)

Após qualquer alteração:
1. `git add -A && git commit -m "tipo: descrição" && git push`
2. Se alterou `dashboard_bq.html` → deploy via GitHub Pages (push para main)
3. Se alterou `api_bq.py` → deploy via `bash deploy_api.sh`:
   ```bash
   gcloud functions deploy api-etiquetei \
     --gen2 --runtime python311 --trigger-http --allow-unauthenticated \
     --entry-point api_dashboard --source . \
     --set-env-vars GCP_PROJECT_ID=dashboard-koti-omie,BQ_DATASET=etiquetei \
     --region us-central1 --memory 512MB --timeout 60s
   ```
4. Se alterou `omie_sync_bq.py` → workflow roda 3x/dia, ou `python3 omie_sync_bq.py` local

NUNCA perguntar "quer commitar?" — sempre fazer automaticamente.

## Dashboard — Abas (atualizado 22/04/2026)

| Aba | Regime | Conteúdo principal |
|-----|--------|--------------------|
| **Visão Geral** | Misto | 5 KPIs (Receita Período, Resultado Op, Caixa Total, Meses de Caixa, Inadimplência) + sparklines 6m-ish (Receita vs Despesa Op, Variação Caixa %, Saldo Bancário, Faturamento, EBITDA, Inadimplência R\$/%) + alertas automáticos + botão PDF |
| **Fluxo de Caixa** | Caixa | KPIs operacionais, Saldo por Conta (D-1 ou fim do período), **Projeção de Saldo 90d** com piso crítico + KPIs 30/60/90, Receita vs Despesa mensal, Resultado mensal, Saldo Bancário Real, Despesas/Receitas por Grupo (1.01 desmembrado em linhas SaaS), Custos em cascata, **Receitas em cascata** (linhas SaaS + Fat. Direto + Financiamento) |
| **Resultado** (ex-Financeiro) | Competência | **DRE Estruturada** (Receita Bruta → DAS → Receita Líquida → CMV → Margem Bruta → Comercial/Pessoal/Admin → EBITDA → Financeiras → Lucro Líquido) com totalizadores e % vertical, Evolução de Margens %, Resultado mensal R\$, Receita vs CMV vs SG&A stacked, SG&A breakdown donut |
| **Receitas** | Caixa (+ Contratos) | KPIs SaaS, **MRR Bridge 12m** (NRR, Churn médio), Receita por Linha, Waterfall acumulado, Receita vs Custo Direto, Top Clientes/Projetos |
| **Geografia** (ex-Projetos) | Caixa | 4 KPIs (UFs atendidas, Top UF, Concentração SP %, HHI), Mapa em tiles por região (cor=receita), Top UFs bar, Ticket Médio por UF, **Top 15 Cidades com filtro de UF**, Tabela detalhada |
| **Contratos** | Misto | 4 KPIs (MRR Atual, Pipeline Onboarding, MRR em 3m, MRR em Risco 12m), **MRR Projetado 12m** (barras entram/saem + linha), **Base Histórica 12m** (novos vs saídas), **Distribuição de Ticket**, Pipeline Onboarding, Vigências Terminando, Donut Status, Faturamento Mensal Realizado, Comissões por Vendedor |
| **Cobrança** | Snapshot atual | Títulos inadimplentes, por linha, top devedores |

## Padrão de dados — Receita Operacional

Globais no topo do script (reutilize via `isRecOp(l)` / `isDespOp(l)`):

```javascript
// Categorias (3 níveis) excluídas da "Receita Operacional":
//  1.01.99 a identificar · 1.02.02 rendimentos · 1.03.* devoluções · 1.04.01-03 recebimento indevido/FD/empréstimos
const REC_OP_EXCLUIR = new Set(['1.01.99','1.04.02','1.04.03','1.04.01','1.02.02','1.03.01','1.03.02','1.03.03','1.03.04','1.03.26']);

// Grupos (2 níveis) excluídos da "Despesa Operacional":
//  2.05 financeiras · 2.07 CAPEX · 2.08 IRPJ/CSLL · 2.09 devoluções · 2.10 empréstimos · 2.11 outros não-op
const DESP_OP_EXCLUIR = new Set(['2.05','2.07','2.08','2.09','2.10','2.11']);
```

`compute()` e `computeCompetencia()` retornam `tERecOp`, `tSDespOp`, `porMesOp` prontos.
Toda aba usa Receita Op como default; Receita Bruta vira sub-label quando diverge >0.

## Toggle de período (filtros do topo)

Default do dashboard: **YTD (últimos 12m rolling)**.

| Botão | Janela | Label KPI |
|-------|--------|-----------|
| Mês | Mês atual | "Receita Mês" |
| Tri | Últimos 3m calendar | "Receita 3M" |
| Ano | Ano anterior inteiro | "Receita Ano {y-1}" |
| YTD | Últimos 12m calendar | "Receita 12M" |
| Tudo | 2025-07 a 2026-07 | "Receita Período" |

Comparativo no KPI Receita usa `getPrevPeriodo()` (calendar-aware, não só shift de dias).
Sparklines respeitam o período filtrado (não mais fixo em 6m).

## DRE — Estrutura (Simples Nacional)

Etiquetei é Simples → DAS substitui ISS/COFINS/IRPJ/CSLL. DRE segue:

```
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

**Ficam FORA do DRE**: CAPEX (2.07), devoluções saída (2.09), empréstimos (2.10), não-op (2.11). Esses são investimentos/não-operacionais — visíveis em Fluxo de Caixa.

## Arquivos removidos/nunca usados

Não criar:
- `bot_telegram.py`, `Dockerfile`, `cloudbuild.yaml`
- `extract_rh.py`, `extract_bp_bq.py`
- `dashboard_rh.html`
- `dados_*.enc`, `rh_data.*`

## ⚠️ Regras de desenvolvimento — dashboard_bq.html

### Canvas IDs devem ser ÚNICOS
Cada `<canvas id="...">` deve ter um ID globalmente único. Chart.js dá erro fatal ao reusar canvas sem destruir o chart anterior.

**Convenção de nomes:** prefixo por aba
- Visão Geral: `spark*` (sparkRecDesp, sparkCaixa, sparkInad, sparkInadVal...)
- Fluxo de Caixa: `chartFluxo*`, `chartProjecaoCaixa`, `chartRecGrupo`, `chartDespGrupo`, `chartReceitasStack`, `chartCustosStack`
- Resultado (DRE): `chartFin*`, `chartMargens`, `chartSgaBreak`
- Receitas: `chartRec*`, `chartMrrBridge`
- Geografia: `chartGeo*` (chartGeoTop, chartGeoTicket, chartGeoCidades)
- Contratos: `chartContratos*`, `chartMrrProj`, `chartCtrHistorico`, `chartCtrTicket`, `chartComissao*`
- Cobrança: `chartCobranca*`

### renderAll() usa try/catch por aba
```javascript
try { renderVendas(dc) } catch(e) { console.error('renderVendas', e) }
```
Erro em uma aba não quebra as outras.

### Destruir antes de recriar
```javascript
if (charts.meuChart) { charts.meuChart.destroy(); delete charts.meuChart; }
charts.meuChart = new Chart(...)
```

### innerHTML com dados dinâmicos
Hook de segurança pode bloquear. Use helper de escape quando puxar `cliente_nome` etc.:
```javascript
const _esc = s => String(s==null?'':s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
```
Construa HTML com concatenação de strings em vez de template literals se o hook reclamar.

### Testar todas as abas após qualquer mudança
Clicar em cada aba e verificar console. Valide com:
```bash
cd ~/dashboard-etiquetei && python3 -c "
import re
html=open('dashboard_bq.html').read()
scripts=re.findall(r'<script>(.*?)</script>',html,re.DOTALL)
open('/tmp/dash.js','w').write(scripts[1])
" && node --check /tmp/dash.js
```

## ⚠️ Regras de desenvolvimento — omie_sync_bq.py

### APIs Omie têm page sizes diferentes
- A maioria aceita `registros_por_pagina: 200`
- **Contratos** (`servicos/contrato`) aceita **máximo 50**, chave de retorno é `contratoCadastro`
- Doc oficial: https://developer.omie.com.br/service-list/

### Rate limiting
- API Omie retorna 403 com muitas chamadas em sequência
- `time.sleep(0.1)` entre páginas
- Testes locais dão 403 às vezes — validar via GitHub Actions

### ALTER TABLE ao adicionar coluna
`CREATE TABLE IF NOT EXISTS` não altera tabela existente. Adicionar coluna:
```bash
bq query --use_legacy_sql=false "ALTER TABLE \`dashboard-koti-omie.etiquetei.clientes\` ADD COLUMN IF NOT EXISTS cidade STRING"
```

## Gotchas — Etiquetei-specific

### cat_cod como string (29/03/2026)
Omie retorna `cat_cod` como int para Etiquetei. Fix: `str(cat_cod)` forçado no sync.

### status_codigo int vs string (30/03/2026)
BigQuery retorna INT64, comparar como `str(r.get("status_codigo", "")) == "10"`.

### dadosFiltrados vs dadosOriginal — contratos (30/03/2026)
Contratos são cadastro (não transações). Usar `dadosOriginal.contratos.lista`.

### Filtro de receita SaaS — comissão (30/03/2026)
Filtrar por `1.01.*` (todas as linhas SaaS), não só 1.01.02.

### Comissões cruzam contratos × lançamentos (30/03/2026)
- Vendedor vem do **contrato** (nCodVend)
- Comissão paga vem dos **lançamentos** (cat 2.02.01)
- Receita do cliente vem dos **lançamentos** (cat 1.01.*)

### Cidade vem com sufixo "(UF)" (22/04/2026)
Omie retorna `cidade: "APARECIDA (SP)"`. No sync, normalizar:
```python
import re
cidade = re.sub(r"\s*\([A-Z]{2}\)\s*$", "", cidade_raw).strip() or None
```
Também puxar `cidade_ibge` (código IBGE do município) — útil para choropleth futuro.

### Status 90 e 99 de contratos
17 contratos com status 90 (15) ou 99 (2) têm `vigencia_fim = 2028-12-31` default. Significado exato não está documentado — pode ser aditivos ou encerrados. Revisar caso-a-caso antes de contar como churn.

### DAS é imposto operacional (Simples)
Categoria `2.06.99` NO DRE substitui IRPJ/CSLL/ISS/COFINS. Não tem `2.08` (IRPJ separado) para Etiquetei.

## Criptografia e Autenticação

- **Login dashboard**: PBKDF2 + SHA-256, salt `etiquetei2026_salt_`, 100.000 iterações
- **API key**: derivada da senha em runtime via PBKDF2, salt `etiquetei2026_api_key_salt`, 100K iter. Nunca hardcoded.
- **Cloud Function**: valida header `X-API-Key` via env var `DASHBOARD_API_KEY`. Sem key → 401. Se var não setada, auth passa (tolerância).
- **Senha**: NÃO documentar senhas em plaintext neste arquivo.

## Status da implementação (22/04/2026)

### ✅ Recente (sessão 22/04)
- **Receita Operacional padronizada** em todas as abas (globais REC_OP_EXCLUIR / DESP_OP_EXCLUIR)
- **Financeiro → Resultado** com DRE estruturada + margens temporais
- **Projetos → Geografia** com heatmap por UF + cidades (drill-down)
- **Contratos**: projeção MRR 12m, pipeline onboarding, vigências terminando, histórico novos/saídas, distribuição de ticket
- **Fluxo de Caixa**: projeção de saldo 90d + KPIs 30/60/90 + piso crítico
- **Receitas**: MRR Bridge 12m + NRR + Churn médio
- **Visão Geral**: toggle Caixa/Compet. em Receita Mês, label dinâmico por período, sparklines respeitam filtro, sparkline Inadimplência (R\$/%)
- **Toggles redefinidos**: Tri = últimos 3m, Ano = ano anterior completo, YTD = últimos 12m rolling
- **Default YTD** ao abrir
- **Sync expandido**: cidade (normalizada) + cidade_ibge

### ⏳ Pendente (baixa-média prioridade)
- Choropleth SVG real (hoje = tiles por região)
- Bubble map por município (IBGE já disponível no cadastro)
- YoY real (linha pontilhada do mesmo mês ano anterior)
- Cobrança tab — ampliar (aging por faixa, curva de recuperação)
- Cohort analysis (retenção por mês de entrada)
- Identidade visual Etiquetei (cores ainda do Koti)
- Revisar status 90 e 99 dos contratos
- Adaptar `test_pipeline.py` e `test_api.py`
- Export PDF estruturado da aba Resultado
