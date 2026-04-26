# 001 - Completar YoY restante no dashboard Etiquetei

## Objetivo
Completar a cobertura de comparativos YoY nos graficos mensais do dashboard Etiquetei que ainda nao exibem a linha do mesmo periodo do ano anterior. O resultado esperado e reduzir inconsistencias analiticas entre abas e deixar a leitura de tendencia comparativa mais completa para uso executivo.

## Contexto
O dashboard ja tem infraestrutura parcial de YoY em `dashboard_bq.html`, incluindo helper `getYoYMonth()` e linhas pontilhadas em alguns graficos da Visao Geral, Fluxo de Caixa e Resultado. A documentacao do projeto ainda lista "Completar YoY nos graficos mensais que ainda nao tem linha de ano anterior" como pendencia analitica.

## Inputs
- Arquivo principal do frontend: `/Users/antoinekmouawad/dashboard-etiquetei/dashboard_bq.html`
- Referencia operacional do projeto: `/Users/antoinekmouawad/dashboard-etiquetei/CLAUDE.md`
- Documentacao do projeto no vault: `/Users/antoinekmouawad/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Suite offline para nao-regressao basica:
  - `/Users/antoinekmouawad/dashboard-etiquetei/test_api.py`
  - `/Users/antoinekmouawad/dashboard-etiquetei/test_pipeline.py`

## Outputs esperados
- Arquivo modificado: `dashboard_bq.html`
- Arquivo modificado: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Comportamento observavel:
  - cada grafico mensal escolhido passa a exibir serie YoY com estilo visual coerente com o restante do dashboard;
  - a linha de ano anterior respeita a mesma regra de periodo do grafico principal;
  - `node --check` no JS extraido do HTML passa sem erro.

## Suposições explícitas
- O YoY deve reutilizar as mesmas fontes/calculos ja usados nos graficos equivalentes, evitando criar definicoes paralelas de receita, despesa ou resultado.
- O executor pode inspecionar `dashboard_bq.html` para decidir exatamente quais graficos mensais ainda nao possuem YoY.
- O ambiente local tem `python3`, `node` e dependencias suficientes para rodar as validacoes basicas.
- **Regra:** se a definicao de "graficos mensais restantes" estiver ambigua a ponto de exigir decisao de produto, o executor deve PARAR e perguntar, nao improvisar.

## Restrições
- Nao tocar `api_bq.py`, `omie_sync_bq.py`, Cloud Function, BigQuery schema nem pipeline.
- Nao implementar novas metricas (ex.: Quick Ratio v2) nem redesign visual amplo.
- Nao mexer em dados de outros clientes.
- Nao commitar direto em `main` se a politica de push direto continuar bloqueada; usar branch de feature se necessario.

## Passos sugeridos
1. Mapear os graficos com YoY ja implementado e os graficos mensais ainda sem YoY em `dashboard_bq.html`.
   Pronto quando houver uma lista objetiva de alvos.
2. Para cada grafico alvo, identificar a serie principal, sua fonte de dados e a regra de periodo usada.
   Pronto quando estiver claro qual e o "mesmo mes do ano anterior" correto para aquele grafico.
3. Implementar a serie YoY reutilizando helpers existentes (`getYoYMonth()` e caches all-time quando fizer sentido).
   Pronto quando cada grafico alvo renderizar sem erro e com linha visual coerente.
4. Validar se a legenda, rotulo e estilo nao poluem a leitura nem quebram o layout mobile/desktop.
   Pronto quando o grafico permanecer legivel e responsivo.
5. Atualizar a documentacao do Obsidian marcando a pendencia como concluida, parcial ou redefinida.
   Pronto quando a nota refletir exatamente o que foi entregue.

## Critérios de aceite
- [ ] Existe uma lista explicita dos graficos mensais alvo e ela bate com o estado real do `dashboard_bq.html`
- [ ] Cada grafico alvo exibe linha YoY do mesmo mes do ano anterior com estilo coerente (pontilhada/branca/translucida ou padrao local equivalente)
- [ ] Nenhum grafico que ja tinha YoY regrediu ou mudou de definicao sem necessidade
- [ ] `python3 -m unittest test_pipeline.py test_api.py` continua passando
- [ ] O JS extraido de `dashboard_bq.html` passa em `node --check`
- [ ] `git diff --check` fica limpo
- [ ] A documentacao em `Implementação.md` foi atualizada com o resultado

## Comandos de validação
```bash
python3 -m unittest test_pipeline.py test_api.py

python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dashboard_etiquetei.js','w').write('\n'.join(scripts))"
node --check /tmp/dashboard_etiquetei.js

git diff --check

rg -n "YoY|Ano Ant|ano anterior|pontilhada" dashboard_bq.html
```

## Edge cases a considerar
- Graficos que usam regime de caixa e competencia em fontes diferentes nao devem compartilhar a mesma serie YoY por conveniencia.
- Graficos com poucos meses de historico podem gerar `null` em varios pontos; a serie YoY deve tolerar lacunas sem quebrar o chart.
- Se um grafico mensal usar agregacao rolling em vez de mes calendario puro, a comparacao YoY precisa ser explicitamente consistente com essa escolha.
- Se incluir uma nova serie YoY quebrar a legibilidade ou o grid, preferir limitar a cobertura aos graficos que comportam a comparacao com clareza e documentar o resto.

---

## Resultado da execução

- **Status:** concluído
- **Data de execução:** 2026-04-26
- **O que rodou com sucesso:**
  - Mapeamento dos gráficos mensais e cruzamento com os que já tinham YoY.
  - Gráficos com YoY adicionado nesta entrega (6):
    - `sparkEbitda` (Visão Geral) — linha YoY pontilhada usando `computeAllTimeDre()[mes].ebitda`. Suggested min/max ajustados para acomodar a série YoY.
    - `chartFluxoVarCaixa` (Fluxo de Caixa, Resultado Mensal R$) — YoY do resultado caixa via `getAllPorMes()` (mesma base do gráfico Receita vs Despesa Mensal já existente).
    - `chartMargens` (Resultado, Evolução de Margens %) — apenas Margem EBITDA Ano Ant. adicionada (decisão de design para evitar poluir um chart com 3 séries com 3 séries YoY adicionais; documentado como desvio).
    - `chartRecStack` (Receitas, stacked por linha) — linha YoY de TOTAL das categorias `LINHAS_RECEITA` (1.01.*), regime caixa, sobreposta sem stack.
    - `chartContratosFat` (Contratos, Faturamento Mensal Realizado) — YoY da soma 1.01.* entrada por mês (regime caixa via `l.data`).
    - `chartComissaoEvo` (Contratos, Evolução de Comissões) — YoY de 2.02.01 saida por mês (regime caixa).
  - Estilo visual coerente com os YoY pré-existentes: `rgba(255,255,255,.25)` (ou `rgba(74,144,255,.35)` para a linha azulada do Margens), `borderDash:[5,5]` em charts grandes / `[3,3]` em sparklines, `pointRadius:2` em charts grandes / `0` em sparklines, `spanGaps:false`, `datalabels:{display:false}`.
  - Validações: `python3 -m unittest test_pipeline.py test_api.py` → 83 tests, 68 OK, 15 skipped. `node --check` no JS extraído → OK. `git diff --check` → clean.
- **O que falhou ou ficou pendente:**
  - Nenhum item pendente do escopo de "completar YoY restante".
  - YoY desligado (decisão consciente, documentado abaixo) em: `sparkCaixa`, `chartFluxoSaldo` (saldo absoluto não compõe série temporal típica para YoY); `sparkInadVal`, `sparkInad`, `chartCobVencMes` (snapshot da posição atual agrupado por mês de vencimento original, não série temporal); demais charts não-mensais (donuts, top barras, mapas, waterfalls, cohort, projeções forward, MRR Bridge — esse último tem novos/churn próprios).
- **Desvios do plano original (e por quê):**
  - Em `chartMargens`, adicionada apenas YoY de Margem EBITDA (e não de Bruta nem de LL) para preservar legibilidade. O gráfico já tem 3 linhas; 6 linhas próximas brancas pontilhadas tornariam a leitura confusa. Margem EBITDA foi escolhida por ser a métrica operacional mais sensível ao período e, normalmente, a mais comparada YoY em análise CFO. Decisão alinhada com o edge case do spec: "Se incluir uma nova serie YoY quebrar a legibilidade ou o grid, preferir limitar a cobertura aos graficos que comportam a comparacao com clareza e documentar o resto."
  - YoY do `sparkEbitda` usa o cálculo do DRE all-time (modo "Imp Real"), independente do toggle "Imp Real / Imp 11% Teórico" do gráfico principal. A linha YoY portanto reflete sempre a base real histórica. Razão: o modo teórico é uma simulação prospectiva sobre o período corrente, não tem equivalente histórico fiel; comparar período corrente teórico contra histórico real seria coerente e mais útil que duas curvas teóricas.
- **Observações para tarefas futuras:**
  - Para um Quick Ratio v2 (já no backlog) ou outras métricas SaaS futuras, seguir o mesmo padrão de cache global (`computeAllTimeDre`, `getAllPorMes`) para fontes de YoY.
  - Se em algum momento o `chartMargens` precisar de YoY completo (Bruta + EBITDA + LL), considerar separar visualmente: ou usar tabs internas (Bruta/EBITDA/LL) ou um gráfico em pequenos múltiplos. Adicionar 3 linhas YoY pontilhadas no atual quebraria.
  - YoY do MRR Bridge pode fazer sentido no futuro (comparar MRR de 12 meses atrás vs MRR atual em pontos equivalentes), mas é tarefa diferente: precisa de histórico de assinaturas, não de lançamentos.
