# 003 - Analise mensal de despesas de marketing

## Objetivo
Adicionar ao Dashboard Etiquetei uma analise mensal de despesas de marketing, quebrada por tipo de despesa, para apoiar leitura de eficiencia comercial e impacto no Resultado. A entrega deve ajudar a responder quanto foi gasto em marketing por mes, em quais tipos de despesa e qual o peso disso sobre receita e SG&A.

## Contexto
A aba mais adequada e **Resultado**, porque marketing faz parte de SG&A / Comercial na DRE e a analise buscada e de performance operacional, nao apenas fluxo de pagamento. O dashboard ja calcula DRE, SG&A e composicao Comercial/Pessoal/Admin em `dashboard_bq.html`; a nova analise deve reaproveitar esses dados sem alterar backend ou pipeline. Antes de implementar visual, e necessario validar se o plano de contas/fornecedores/descricoes do Omie permitem separar marketing por tipo de forma confiavel.

## Inputs
- Frontend principal: `/Users/antoinekmouawad/dashboard-etiquetei/dashboard_bq.html`
- Referencia operacional: `/Users/antoinekmouawad/dashboard-etiquetei/CLAUDE.md`
- Documentacao do projeto: `/Users/antoinekmouawad/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Dataset BigQuery, se acessivel: `dashboard-koti-omie.etiquetei`
- Tabelas esperadas: `lancamentos`, `categorias` ou equivalentes ja usadas pela API/dashboard

## Outputs esperados
- Arquivo modificado: `dashboard_bq.html`
- Arquivo modificado: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Comportamento observavel:
  - aba Resultado exibe um bloco de despesas de marketing mensal por tipo;
  - o bloco mostra KPIs de apoio, no minimo `MKT no periodo`, `% da Receita` e `MKT / SG&A`;
  - a quebra por tipo e documentada e rastreavel para categorias/fornecedores/descricoes reais.

## Suposições explícitas
- Marketing deve ser analisado na aba Resultado, proximo de DRE/SG&A.
- O regime preferencial e competencia (`data_vencimento`) para manter coerencia com Resultado; se os dados do dashboard local para essa analise estiverem mais consistentes em caixa, o executor deve documentar a escolha.
- O executor pode usar BigQuery para mapear categorias reais; se BigQuery nao estiver acessivel, deve preparar as queries e parar antes de implementar classificacao especulativa.
- A classificacao por tipo deve ser conservadora: so criar bucket quando houver sinal claro por categoria, fornecedor ou descricao.
- **Regra:** se nao houver dados suficientes para quebrar marketing por tipo com confianca, o executor deve PARAR e reportar o mapeamento encontrado, nao inventar buckets.

## Restrições
- Nao tocar `api_bq.py`, `omie_sync_bq.py`, Cloud Function, schema BigQuery ou pipeline.
- Nao alterar calculos existentes de DRE, SG&A, Quick Ratio, YoY, Curva de Recuperacao ou MRR.
- Nao criar nova aba nesta tarefa.
- Nao criar novas dependencias frontend.
- Nao mexer em dados de outros clientes.
- Nao commitar direto em `main` se a politica de push direto continuar bloqueada; usar branch de feature.

## Passos sugeridos
1. Auditar dados de marketing no Omie/BigQuery.
   Pronto quando houver uma lista de categorias/fornecedores/descricoes candidatas a marketing, com valores e volumes.
2. Definir regra de classificacao por tipo.
   Pronto quando cada tipo tiver criterio claro, por exemplo categoria exata, prefixo de categoria, fornecedor ou palavra-chave em descricao.
3. Validar se a classificacao cobre parcela relevante das despesas comerciais.
   Pronto quando estiver claro o total classificado como marketing e o que ficou fora.
4. Implementar o bloco na aba Resultado, abaixo ou proximo de SG&A.
   Pronto quando houver grafico mensal por tipo e KPIs de apoio sem quebrar layout.
5. Documentar a classificacao e limitacoes.
   Pronto quando `Implementação.md` explicar quais tipos foram usados e quais dados sustentam a quebra.

## Critérios de aceite
- [ ] O executor auditou categorias/fornecedores/descricoes antes de implementar buckets
- [ ] A classificacao de marketing por tipo tem regra explicita e conservadora
- [ ] A aba Resultado mostra despesas de marketing mensais por tipo
- [ ] O bloco inclui KPIs de apoio: `MKT no periodo`, `% da Receita`, `MKT / SG&A`
- [ ] Títulos/labels deixam claro o regime usado (competencia ou caixa)
- [ ] Nenhuma metrica existente de DRE/SG&A muda de definicao
- [ ] `python3 -m unittest test_pipeline.py test_api.py` continua passando
- [ ] O JS extraido de `dashboard_bq.html` passa em `node --check`
- [ ] `git diff --check` fica limpo
- [ ] `Implementação.md` foi atualizado com resultado, classificacao e limitacoes

## Comandos de validação
```bash
# Sanity check offline
python3 -m unittest test_pipeline.py test_api.py

# JS syntax check
python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dashboard_etiquetei.js','w').write('\n'.join(scripts))"
node --check /tmp/dashboard_etiquetei.js

# Diff hygiene
git diff --check

# Auditoria sugerida em BigQuery, se credenciais estiverem disponiveis
bq query --use_legacy_sql=false "
SELECT
  categoria,
  categoria_nome,
  fornecedor_nome,
  COUNT(*) qtd,
  ROUND(SUM(valor), 2) total
FROM \`dashboard-koti-omie.etiquetei.lancamentos\`
WHERE tipo = 'saida'
  AND (
    categoria LIKE '2.02%'
    OR LOWER(categoria_nome) LIKE '%marketing%'
    OR LOWER(categoria_nome) LIKE '%midia%'
    OR LOWER(categoria_nome) LIKE '%mídia%'
    OR LOWER(categoria_nome) LIKE '%trafego%'
    OR LOWER(categoria_nome) LIKE '%tráfego%'
    OR LOWER(categoria_nome) LIKE '%ads%'
    OR LOWER(categoria_nome) LIKE '%publicidade%'
    OR LOWER(categoria_nome) LIKE '%propaganda%'
  )
GROUP BY categoria, categoria_nome, fornecedor_nome
ORDER BY total DESC
"
```

## Edge cases a considerar
- Despesas de marketing podem estar misturadas em `Comercial (2.02)` com comissoes ou vendas; nao classificar tudo como marketing sem evidencia.
- Fornecedores podem prestar servicos mistos; se o fornecedor for ambiguo, manter em `Outros/Não classificado` ou parar para perguntar.
- Grafico mensal com muitos tipos pode ficar ilegivel; limitar a 4-6 tipos e agregar o resto em `Outros MKT`, desde que a regra seja documentada.
- Se o periodo filtrado tiver poucos dados, o grafico deve continuar legivel e os KPIs devem mostrar zero/tracejado sem quebrar.
- A despesa de comissao (`2.02.01`) nao deve ser automaticamente tratada como marketing; ela ja tem analise propria em Contratos/Comissoes.

---

## Resultado da execução

- **Status:** concluído
- **Data de execução:** 2026-04-27
- **Auditoria realizada (BigQuery)**: query agregada por `categoria_codigo` + `cliente_nome` em `dashboard-koti-omie.etiquetei.lancamentos` filtrando `tipo='saida'` e `categoria_codigo LIKE '2.02%'` + termos de marketing/mídia/ads/publicidade no `categoria_nome`. Resultado:

  | Código | Categoria Omie | Qtd | Total | Decisão |
  |---|---|---|---|---|
  | 2.02.99 | Eventos | 40 | R$ 276.478,35 | ✅ Marketing — top: Burger Tour Eventos (R$ 240k, ativação de marca em circuito gastronômico) e Lab Jota Marketing Digital (R$ 30k) |
  | 2.02.01 | Comissões | 130 | R$ 51.950,42 | ❌ Excluído pelo spec (analisado em Contratos) |
  | 2.02.02 | Marketing | 26 | R$ 46.050,00 | ✅ Marketing — Bianca Fraga, Agência Cactus, Lucas Marques (freelancers/agências) |
  | 2.02.03 | Despesas de Viagens | 42 | R$ 26.619,97 | ✅ Marketing (incluído por decisão do usuário) — Vinicius Polo (R$ 18k, 21 pgtos), João Quintella (vendedores) |
- **Direção implementada (3 buckets, classificação por `categoria_codigo`)**:
  1. **Marketing** (`2.02.02`) — purple `#A78BFA`
  2. **Eventos** (`2.02.99`) — orange `#FB923C`
  3. **Viagens comerciais** (`2.02.03`) — cyan `#22D3EE`
  Comissões (`2.02.01`) ficam fora; já têm gráfico próprio em Contratos.
- **O que rodou com sucesso**:
  - Auditoria BQ → 3 categorias concretas com fornecedores rastreáveis identificadas. Total **R$ 349.148,32** no histórico completo.
  - Bloco novo full-width na **aba Resultado**, abaixo do par "Receita vs Custos vs SG&A" + "SG&A Composição". Stacked bar mensal por bucket + linha pontilhada do total mensal.
  - **KPI-âncora no header do card** (`#kpiMktResultado`): `MKT no período` (orange), `% Receita Líq.` e `MKT / SG&A` (formatados com `,` como separador decimal, `—` quando denominador for zero).
  - Regime competência (`data_vencimento`), coerente com aba Resultado e regime-badge `Competência` no título.
  - Reuso de `dre.receitaLiquida` e `dre.sgaTotal` já calculados — sem definição paralela de receita ou SG&A.
  - Empty state implementado: se `mktTotalPeriodo === 0`, KPI mostra `—` e canvas é limpo.
  - Validações: `python3 -m unittest test_pipeline.py test_api.py` → 83 tests, 68 OK, 15 skipped. `node --check` → OK. `git diff --check` → clean. Sanity BQ confirma R$ 349.148,32 (Marketing 46.050 + Eventos 276.478 + Viagens 26.620).
- **O que falhou ou ficou pendente**: nada do escopo. A pendência genérica "análise mensal de despesas de marketing" sai do backlog.
- **Desvios do plano original (e por quê)**:
  - **`2.02.03 Despesas de Viagens` foi incluído** como 3º bucket de marketing por decisão do usuário durante a execução. Motivo: vendedores (Vinicius Polo, João Quintella) representam custo go-to-market — afins ao bloco de eficiência comercial que a aba Resultado quer expor. Sem essa decisão, a v1 teria 2 buckets (Marketing + Eventos).
  - **Não foi feita classificação por fornecedor/descrição**, apesar de a auditoria mostrar concentração forte (Burger Tour 87% de Eventos, Bianca/Cactus 78% de Marketing). Conforme o spec ("conservadora: só criar bucket quando houver sinal claro por categoria, fornecedor ou descrição"), regra única e auditável por categoria foi escolhida — o usuário pode futuramente refinar para "Marketing Digital" / "Ativação Presencial" / "Conteúdo" se quiser, mas isso requer manter um mapping fornecedor→tipo que envelhece com a base.
  - **Lab Jota Marketing Digital** está cadastrado em `2.02.99 Eventos` no Omie (R$ 30.4k) — provavelmente classificação fora-do-padrão na origem. Mantido em Eventos para respeitar o plano de contas atual, mas registrado como limitação.
- **Observações para tarefas futuras**:
  - Se v2 quiser separar "Marketing Digital" vs "Ativação Presencial" vs "Conteúdo/Freelancer", seria pelo cruzamento `categoria_codigo` + `cliente_nome` (lista mantida): Lab Jota / Agência Cactus → Digital; Burger Tour Eventos → Ativação; Bianca/Lucas/Giovanna → Conteúdo. Recomendo só fazer se a base de fornecedores estabilizar.
  - Considerar adicionar um campo CAC (Custo de Aquisição = MKT / clientes novos no período) puxando do MRR Bridge `novoMrr` ou da contagem de contratos com `vigencia_inicio` no período.
  - O Omie tem campo `tipo_documento` em fornecedor (PF / PJ) que pode revelar mais granularidade de custo de marketing PJ x PF — não acessível no payload atual, fica para revisão de schema.
