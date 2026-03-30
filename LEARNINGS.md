# Aprendizados — Dashboard Etiquetei

> Documento vivo. Registre bugs, decisões e padrões aqui para que sessões futuras
> (humanas ou AI) não repitam erros. Formato: data, contexto curto, lição.

---

## 🐛 Bugs e Armadilhas

### Template literals com ternário + CSS (29/03/2026)
**Problema:** `${val?'var(--green)':'var(--border)';font-size:11px}` — o `;` fecha a expressão dentro do `${}`.
**Fix:** Fechar o `}` antes do `;`:  `${val?'var(--green)':'var(--border)'};font-size:11px`
**Regra:** Nunca colocar `;` de CSS dentro de `${}`. O ternário termina, depois a propriedade CSS continua fora.

### Canvas IDs duplicados (29/03/2026)
**Problema:** Abas diferentes usavam o mesmo `id` de canvas → Chart.js dava erro fatal.
**Fix:** Prefixar por aba (ex: `chartRec*`, `chartFin*`, `chartContratos*`).
**Regra:** Documentado em CLAUDE.md § "Canvas IDs devem ser ÚNICOS".

### cat_cod como string (29/03/2026)
**Problema:** Omie retorna `cat_cod` como int para Etiquetei (diferente do Koti que era string).
**Fix:** `str(cat_cod)` forçado no sync.
**Regra:** Sempre converter campos de código para `str()` antes de comparar.

### API Omie — Contratos page size (29/03/2026)
**Problema:** Contratos aceita max 50 `registros_por_pagina` (não 200 como outras APIs).
**Fix:** Valor hardcoded 50 + chave de lista correta: `contratoCadastro`.
**Regra:** Sempre checar doc da API antes de adicionar novo endpoint.

### API Omie — Rate Limiting 403 (29/03/2026)
**Problema:** Muitas chamadas em sequência → 403 Forbidden.
**Fix:** `time.sleep(0.1)` entre chamadas paginadas.
**Regra:** Testes locais frequentes dão 403. Validar via GitHub Actions quando possível.

---

## 📐 Decisões de Arquitetura

### Regime por aba (29/03/2026)
- **Caixa:** Fluxo de Caixa, Financeiro, Cobrança
- **Competência:** Projetos, Visão Geral (misto)
- **Motivo:** Cada visão tem um propósito diferente. Misturar regimes gera confusão.

### Comissões cruzam contratos × lançamentos (30/03/2026)
- Vendedor vem do **contrato** (`nCodVend` → API vendedores)
- Comissão paga vem dos **lançamentos** (cat `2.02.01`, tipo saída)
- Receita dos clientes vem dos **lançamentos** (cat `1.01.*`, tipo entrada)
- A memória de cálculo cruza: receita real × % comissão × pago vs calculado

### PASS_HASH usa PBKDF2 (29/03/2026)
- SHA-256 simples substituído por PBKDF2 (10K iterations + salt)
- Salt: `etiquetei2026_salt_`
- Gerar novo: `node -e "..."` (ver CLAUDE.md)

---

## 🔄 Padrões de Deploy

### Sequência correta de deploy
1. Validar sintaxe (Python + JS)
2. `git add -A && git commit -m "tipo: msg" && git push`
3. Se alterou `api_bq.py` → `bash deploy_api.sh`
4. Se alterou `omie_sync_bq.py` → rodar sync (local ou GitHub Actions)
5. Verificar API: `curl -s <URL> | python3 -c "..."`

### Crash recovery (30/03/2026)
- Sempre checar `git status` + `git diff` para ver trabalho não commitado
- Checar `gcloud functions describe` para saber se o último deploy completou
- Checar BigQuery schema para saber se o sync rodou

---

## 📋 Multi-cliente: Koti → Etiquetei

### Itens adaptados (29/03/2026)
| Item | Koti | Etiquetei |
|------|------|-----------|
| `CONTAS_IGNORAR` | IDs específicos | `set()` vazio |
| `is_faturamento_direto` | Lógica ativa | Sempre `False` |
| `PASS_HASH` | Senha Koti | Senha `etiquetei2026` |
| `cat_cod` | String nativa | Forçar `str()` |
| `BQ_DATASET` | `studio_koti` | `etiquetei` |
| Cloud Function | `api-koti` | `api-etiquetei` |

---

*Última atualização: 30/03/2026*
