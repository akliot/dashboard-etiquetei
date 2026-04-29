# 004 - QA final do dashboard pos-rebrand e pos-marketing

## Objetivo
Fazer um QA visual e funcional consolidado do Dashboard Etiquetei apos as ultimas tres entregas (Curva de Recuperacao, Identidade Visual teal, Analise mensal de Marketing) para garantir que (a) nao ha regressao visual em nenhuma aba, (b) a paleta teal mantem legibilidade e contraste em desktop e mobile, e (c) os blocos novos coexistem sem poluir a leitura. O resultado esperado e um relatorio com pendencias visuais ou bugs reais, sem precisar fechar features novas.

## Contexto
A `main` em `7f8aff3` ja contem Quick Ratio v1, Curva de Recuperacao, YoY restante, Identidade Visual teal e Analise mensal de Marketing. Cada uma dessas entregas foi validada isoladamente, mas nunca foi feita uma passada visual de ponta a ponta no dashboard montado. O frontend e single-page (`dashboard_bq.html`) e qualquer regressao de layout ou contraste afetaria todos os clientes Etiquetei imediatamente apos um push para `main` (GitHub Pages atualiza automatico). Esta tarefa e exclusivamente de QA: inspeciona, mede, registra. Nao e para refatorar nem para abrir feature.

## Inputs
- Frontend principal: `/Users/antoinekmouawad/dashboard-etiquetei/dashboard_bq.html`
- Referencia operacional: `/Users/antoinekmouawad/dashboard-etiquetei/CLAUDE.md`
- Estado atual do projeto: `/Users/antoinekmouawad/dashboard-etiquetei/claude-handoff/CURRENT_STATE.md`
- Documentacao do projeto: `/Users/antoinekmouawad/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Specs concluidos relevantes para esta auditoria: `specs/001`, `specs/002`, `specs/003`
- Dashboard publicado: `https://akliot.github.io/dashboard-etiquetei/dashboard_bq.html`
- Ferramenta opcional: MCP Playwright (`mcp__plugin_playwright_playwright__browser_*`) para capturas e medicoes de viewport

## Outputs esperados
- Arquivo modificado/criado: este proprio spec, com a secao `Resultado da execução` preenchida e contendo um relatorio estruturado por aba.
- Arquivo modificado: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md` apenas se o QA encontrar pendencias relevantes para registrar; caso contrario, anotar somente que o QA passou.
- Comportamento observavel:
  - relatorio do QA aponta especificamente quais abas foram inspecionadas e em quais resolucoes;
  - cada bloco novo (Quick Ratio, MRR Bridge YoY, Curva de Recuperacao, Marketing) tem item de checagem proprio;
  - bugs achados (se houver) ficam descritos como achados, sem fix neste spec.
- Sem alteracao em `dashboard_bq.html`, `api_bq.py`, `omie_sync_bq.py` ou pipeline, exceto se o QA encontrar bug critico que justifique correcao minima dentro do mesmo PR (e nesse caso documentar o desvio).

## Suposições explícitas
- O dashboard publicado em GitHub Pages reflete o `dashboard_bq.html` atual da `main`. Se houver delay de cache, o executor deve testar via servidor local (`python3 -m http.server`) abrindo `dashboard_bq.html` direto.
- O executor tem acesso a um navegador (manual ou via MCP Playwright) para inspecao visual. Se nao tiver, deve documentar o bloqueio e parar.
- Existe pelo menos uma sessao de login valida disponivel (senha do dashboard). Se nao houver, o QA fica limitado a inspecao do HTML/CSS/JS estatico, e isso deve ser registrado.
- O conjunto de dados em producao e estavel o suficiente para o QA: nao se espera que graficos venham vazios ou com quebra de tipo. Se vier vazio, registrar e nao tratar como bug.
- **Regra:** se alguma suposicao acima estiver errada (ex.: dashboard publicado nao corresponde ao codigo), o executor deve PARAR e reportar antes de continuar o QA.

## Restrições
- Nao tocar `api_bq.py`, `omie_sync_bq.py`, Cloud Function, schema BigQuery ou pipeline.
- Nao alterar calculos de DRE, SG&A, Quick Ratio, YoY, Curva de Recuperacao, Marketing ou MRR.
- Nao reabrir decisoes ja tomadas e documentadas nos specs 001/002/003 (ex.: nao discutir se Margem EBITDA YoY deveria virar 3 linhas YoY em `chartMargens`).
- Nao alterar a paleta teal nem reverter a identidade visual.
- Nao criar nova aba, nova feature analitica ou novo grafico nesta tarefa.
- Nao apagar branches remotas mergeadas sem confirmacao.
- Nao commitar direto em `main`. Usar branch de feature.

## Passos sugeridos
1. Sincronizar a base local com `origin/main` e abrir `dashboard_bq.html` em navegador (servidor local ou GitHub Pages).
   Pronto quando o dashboard renderizar a Visao Geral apos login sem erro de console.
2. Inspecionar **cada aba** (Visao Geral, Fluxo de Caixa, Resultado, Receitas, Geografia, Contratos, Cobranca) em **desktop (>=1280px)** e **mobile (<=768px)**, capturando observacoes em texto.
   Pronto quando houver uma linha de "OK" ou descricao de problema para cada aba x viewport.
3. Validar especificamente os blocos novos:
   - **Quick Ratio** (aba Receitas): valor coerente, badge de cor por threshold, tooltip presente, layout do 5o KPI nao quebra a linha em desktop e re-organiza em mobile.
   - **MRR Bridge** (aba Receitas): linha YoY (se houver) discreta, KPIs ao redor inalterados.
   - **YoY pontilhado** (Visao Geral, Fluxo, Resultado, Receitas, Contratos): linha YoY visivel mas nao competindo com a serie principal.
   - **Curva de Recuperacao** (aba Cobranca): KPI-ancora "Recuperado em 30 dias", barras 1-7d/8-15d/16-30d/31-60d/61-90d/90+d/Em aberto, linha de % acumulado, denominador inclui "em aberto".
   - **Marketing mensal por tipo** (aba Resultado): stacked com Marketing/Eventos/Viagens, KPI-ancora MKT no periodo / % Receita / MKT / SG&A, linha pontilhada de total, regime competencia.
   Pronto quando cada bloco tem um item de "OK" ou achado.
4. Verificar legibilidade e contraste:
   - texto sobre `--bg` e sobre `--card` confortavel em monitores claros e escuros;
   - `--accent` teal nao se confunde com `--cyan` (`#22D3EE`) ou `--green` (`#3DDC97`);
   - estados semanticos `--green/--red/--yellow` legiveis em badges, KPIs e barras;
   - hover de KPI cards funciona; focus rings teal aparecem em inputs.
   Pronto quando o relatorio descrever quais elementos passaram e quais nao.
5. Verificar console do navegador:
   - sem `Uncaught` em qualquer aba;
   - sem `Chart with id ... must be destroyed` ou similar;
   - apenas warnings esperados (datalabels, fetch, etc.) podem ser ignorados.
   Pronto quando o relatorio listar warnings residuais e descartaveis.
6. Rodar validacoes tecnicas obrigatorias.
   Pronto quando suite passar como descrito em "Comandos de validação".
7. Preencher `Resultado da execução`, atualizar Obsidian se houver pendencias e abrir PR `docs:` com o spec preenchido.
   Pronto quando o PR estiver aberto e referenciado em `claude-handoff/CURRENT_STATE.md` da proxima rodada.

## Critérios de aceite
- [ ] Cada uma das 7 abas (Visao Geral, Fluxo, Resultado, Receitas, Geografia, Contratos, Cobranca) tem item de QA preenchido para desktop e mobile.
- [ ] Cada bloco novo (Quick Ratio, MRR Bridge, YoY, Curva de Recuperacao, Marketing) tem item proprio com veredito.
- [ ] Console do navegador nao tem erro nao-tratado em nenhuma aba apos login.
- [ ] Paleta teal continua legivel e contrastada; nenhuma cor semantica colide com a cor de marca.
- [ ] Linha YoY pontilhada e visivel mas nao compete com a serie principal em nenhum dos charts cobertos pelo spec 001.
- [ ] Aba Resultado nao ficou pesada apos o bloco Marketing; layout continua coerente em desktop e mobile.
- [ ] `python3 -m unittest test_pipeline.py test_api.py` continua passando.
- [ ] `node --check` no JS extraido de `dashboard_bq.html` passa sem erro.
- [ ] `git diff --check` fica limpo no PR final.
- [ ] `Resultado da execução` deste spec preenchido com relatorio estruturado por aba.
- [ ] Bugs encontrados (se houver) viram itens novos no `claude-handoff/BACKLOG.md` ou specs futuros, nao sao corrigidos dentro deste QA salvo se forem criticos.

## Comandos de validação
```bash
# Sanity offline
python3 -m unittest test_pipeline.py test_api.py

# JS syntax
python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dashboard_etiquetei.js','w').write('\n'.join(scripts))"
node --check /tmp/dashboard_etiquetei.js

# Diff hygiene
git diff --check

# Servidor local rapido para inspecao manual
# (rodar em outro terminal; abrir http://localhost:8000/dashboard_bq.html)
python3 -m http.server 8000

# Auditoria de paleta: confirmar que nao voltou azul Koti acidentalmente
rg -n "#4A90FF|#3b82f6|rgba\\(74,144,255|rgba\\(59,130,246" dashboard_bq.html

# Confirmacao de tokens centrais
rg -n ":root\\{|--accent:|--cyan:" dashboard_bq.html | head -5
```

Para inspecao via MCP Playwright (opcional, se ambiente suportar):

```text
- browser_navigate ate o dashboard publicado ou local
- browser_resize {width: 1440, height: 900}  (desktop)
- browser_take_screenshot por aba
- browser_resize {width: 390, height: 844}   (mobile)
- browser_take_screenshot por aba
- browser_console_messages para checar erros JS
```

## Edge cases a considerar
- Cache de GitHub Pages pode atrasar o deploy do rebrand; se o site publicado mostrar a paleta antiga, validar via `python3 -m http.server` local antes de abrir bug.
- Algum cliente pode ter periodo filtrado com poucos dados, fazendo Curva de Recuperacao ou Marketing aparecerem vazios. Comportamento esperado: KPI mostra `—`, canvas limpo, sem stack trace.
- Mobile pode reorganizar 5 KPIs do MRR Bridge em duas linhas; isso e esperado pelo `auto-fit minmax(200px, 1fr)`. Nao tratar como bug salvo se quebrar leitura.
- O bloco Marketing usa stacked com 3 buckets; se em um mes especifico um bucket for muito maior que os outros, datalabels podem ficar sobrepostos. Registrar como achado, nao como bloqueio.
- Linha YoY de `chartMargens` so existe para Margem EBITDA por decisao do spec 001; nao tratar a ausencia em Margem Bruta e Margem LL como regressao.
- Se o login estiver fora do ar ou bloqueado, o QA visual fica limitado; documentar como pendencia em vez de declarar falha.
- Se algum dos blocos novos sumir em mobile por causa de `display:none` em media query nao prevista, abrir bug; nao tentar consertar dentro deste spec.

---

## Resultado da execução
_Seção preenchida pelo executor (Claude Code) após rodar a tarefa. Não preencher no momento do planejamento._

- **Status:** pendente
- **Data de execução:** 
- **O que rodou com sucesso:** 
- **O que falhou ou ficou pendente:** 
- **Desvios do plano original (e por quê):** 
- **Observações para tarefas futuras:** 
