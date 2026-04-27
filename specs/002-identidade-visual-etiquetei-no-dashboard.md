# 002 - Identidade visual Etiquetei no dashboard

## Objetivo
Dar ao dashboard Etiquetei uma identidade visual propria, reduzindo o "DNA Koti" que ainda aparece na paleta, nos destaques e em alguns componentes. O objetivo e melhorar percepcao de produto final pelo cliente sem alterar metricas, logica de negocio ou fluxos principais.

## Contexto
O dashboard Etiquetei evoluiu bastante em analise financeira, SaaS e cobranca, mas a documentacao do projeto ainda lista "Identidade visual Etiquetei (cores ainda do Koti)" como pendencia visual. O frontend esta concentrado em `dashboard_bq.html`, com estilos e componentes no mesmo arquivo, o que permite uma entrega de branding localizada sem tocar backend.

## Inputs
- Arquivo principal do frontend: `/Users/antoinekmouawad/dashboard-etiquetei/dashboard_bq.html`
- Referencia operacional: `/Users/antoinekmouawad/dashboard-etiquetei/CLAUDE.md`
- Documentacao no vault: `/Users/antoinekmouawad/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Estado atual do dashboard em producao/local para inspecao visual

## Outputs esperados
- Arquivo modificado: `dashboard_bq.html`
- Arquivo modificado: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`
- Comportamento observavel:
  - a paleta principal, destaques e componentes-chave deixam de parecer derivados da Studio Koti;
  - o dashboard continua legivel em desktop e mobile;
  - os estados semanticos (positivo, alerta, risco) continuam claros;
  - `node --check` no JS extraido do HTML passa sem erro.

## Suposições explícitas
- A tarefa e de refinamento visual, nao de redesign estrutural completo.
- O executor pode ajustar variaveis CSS, tokens de cor, badges, botoes, headers, cards e detalhes de acabamento visual, desde que preserve a arquitetura atual da pagina.
- Nao existe um brandbook formal do Etiquetei no repo; a direcao visual deve ser inferida a partir do nome/produto e do contexto do cliente, com escolhas contidas e profissionais.
- **Regra:** se surgir necessidade de reposicionar grandes blocos de layout ou de reescrever a arquitetura de componentes, o executor deve PARAR e perguntar, nao ampliar escopo sozinho.

## Restrições
- Nao tocar `api_bq.py`, `omie_sync_bq.py`, Cloud Function, BigQuery schema ou pipeline.
- Nao alterar calculos financeiros, filtros, logica de YoY, Quick Ratio ou curva de recuperacao.
- Nao criar nova dependencia frontend.
- Nao transformar o dashboard em landing page ou site marketing.
- Nao mexer em dados de outros clientes.
- Nao commitar direto em `main` se a politica de push direto continuar bloqueada; usar branch de feature se necessario.

## Passos sugeridos
1. Mapear os tokens visuais atuais no `dashboard_bq.html` e identificar onde a linguagem ainda remete a Koti.
   Pronto quando houver uma lista clara de cores/tokens/componentes alvo.
2. Definir uma direcao visual Etiquetei.
   Pronto quando houver uma paleta principal, uma paleta de apoio e regras para estados semanticos.
3. Aplicar a nova identidade aos elementos de maior impacto.
   Pronto quando header, tabs, KPI cards, badges, charts highlights e botoes principais estiverem coerentes entre si.
4. Verificar legibilidade e contraste.
   Pronto quando texto, valores financeiros, linhas de grafico e alertas continuarem claros em todas as abas.
5. Validar que a mudanca nao afetou o comportamento funcional.
   Pronto quando o dashboard renderizar sem erro e sem regressao visual obvia.
6. Atualizar o Obsidian marcando a pendencia visual como concluida, parcial ou redefinida.
   Pronto quando a nota refletir exatamente o que foi entregue.

## Critérios de aceite
- [ ] Existe uma direcao visual Etiquetei identificavel e consistente no dashboard
- [ ] O visual deixa de depender da linguagem Koti em cores e destaques principais
- [ ] Estados semanticos continuam claros: positivo, alerta, risco, neutro
- [ ] O dashboard permanece legivel em desktop e mobile
- [ ] `python3 -m unittest test_pipeline.py test_api.py` continua passando
- [ ] O JS extraido de `dashboard_bq.html` passa em `node --check`
- [ ] `git diff --check` fica limpo
- [ ] `Implementação.md` foi atualizado com o resultado

## Comandos de validação
```bash
python3 -m unittest test_pipeline.py test_api.py

python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dashboard_etiquetei.js','w').write('\n'.join(scripts))"
node --check /tmp/dashboard_etiquetei.js

git diff --check

rg -n "var\\(--|#[0-9A-Fa-f]{6}|rgba\\(" dashboard_bq.html
```

## Edge cases a considerar
- Nao quebrar a leitura de numeros financeiros por excesso de cor ou contraste baixo.
- Nao usar a mesma cor para semanticas diferentes (ex.: risco e destaque positivo).
- Graficos com muitas series nao podem perder distinguibilidade depois da troca de paleta.
- Se a identidade visual ideal exigir mudancas muito amplas de layout, limitar a entrega a tokens, superficies, tipografia e componentes de destaque, documentando o restante.

---

## Resultado da execução

- **Status:** concluído
- **Data de execução:** 2026-04-26
- **Direção visual escolhida:** "Etiquetei teal" — accent de marca em **teal `#14B8A6`** sobre superfícies dark com leve viés verde-azulado. Cor associada a frescor / food safety, distinta do azul Studio Koti que originava o template e suficientemente diferenciada do `--cyan` (que foi reposicionado para `#22D3EE`, mais ciano-azul). Cores semânticas (`--green`, `--red`, `--yellow`, `--purple`, `--orange`) foram preservadas inalteradas para não impactar a leitura de charts e KPIs.
- **O que rodou com sucesso:**
  - **Tokens CSS retonalizados em `:root`**:
    - `--bg: #090D16 → #0A1014` (leve viés teal)
    - `--card: #0F1420 → #0F1719`
    - `--card-hover: #161C2E → #162527`
    - `--text: #EAF0FA → #E8F2F0`
    - `--muted: #94a3be → #8FA8A4`
    - `--accent: #4A90FF → #14B8A6` (a mudança de marca)
    - `--accent-strong: #0D9488` (novo token, hover/strong states)
    - `--cyan: #2DD4BF → #22D3EE` (mais ciano-azul para diferenciar do novo accent teal)
  - **Substituição de azul Koti hardcoded** (45 ocorrências eliminadas, agora **0** restantes):
    - `#4A90FF`, `#3b82f6`, `rgba(74,144,255,*)`, `rgba(59,130,246,*)` → todos virando `#14B8A6` / `rgba(20,184,166,*)`.
    - 4 exceções pontuais convertidas para `#0EA5E9` (sky-500), para que continuassem **distintas** do accent: linha de produto **Setup** em `LINHAS_RECEITA` e `LINHAS_COBRANCA`, **Pessoal** no donut SG&A, e a primeira posição da paleta rotativa `cores`.
  - **`#0F1420` hardcoded → `var(--card)`** (sticky theads, kpi-card, vg-kpi, vg-spark, vg-alert), e os 2 que sobravam em chart border/PDF generator agora usam o novo hex `#0F1719`.
  - **Header reformulado**: gradient com viés teal, **brand-mark SVG** (ícone de tag) em quadrado com gradient `var(--accent) → var(--accent-strong)` e box-shadow teal, "Etiquetei" com brand-dot teal, dot de sync com glow verde sutil, `::after` com linha accent decorativa abaixo do header.
  - **Login screen reformulado**: radial gradient sutil, brand-mark maior (44px), botão em accent com texto escuro `#0A1014` (boa legibilidade) e hover trocando para `--accent-strong`, focus ring teal.
  - **Regime badges**: `caixa` virou cyan suave (`#67E8F9`), distinto do accent; `competência` mantido em purple. Os dois sinalizam regime sem competir com a cor de marca.
  - Validações: `python3 -m unittest test_pipeline.py test_api.py` → 83 tests, 68 OK, 15 skipped. `node --check` no JS extraído → OK. `git diff --check` → clean. `rg` final mostra 415 ocorrências de `var(--*)`, `#hex` e `rgba()` (saudável: estilos centralizados).
- **O que falhou ou ficou pendente:**
  - Não houve. Pendência "Identidade visual Etiquetei (cores ainda do Koti)" do backlog visual atendida.
- **Desvios do plano original (e por quê):**
  - Cores semânticas (green/red/yellow/purple/orange) **não foram retonalizadas** — risco alto de quebrar contraste em charts financeiros sem ganho proporcional na percepção de marca. O accent teal sozinho já consolida a identidade. Documentado como decisão consciente alinhada ao edge case do spec ("graficos com muitas series nao podem perder distinguibilidade").
  - `--cyan` foi alterado (`#2DD4BF → #22D3EE`) por necessidade técnica: o novo accent teal `#14B8A6` ficaria visualmente próximo demais do cyan original. Linha "Comissionamento" em `LINHAS_RECEITA` e charts derivados usam essa cor — agora estão mais distintos do accent.
  - Linhas de produto **Setup** (em receita e cobrança) e **Pessoal** (SG&A donut) que anteriormente eram azul Koti foram para `#0EA5E9` em vez do accent teal — assim continuam distintas das séries que de fato querem ser "cor de marca" (saldo bancário, MRR Contratado, MRR Bridge, % acumulado da Curva de Recuperação). Sem essa exceção, múltiplas séries do mesmo chart ficariam indistinguíveis.
- **Observações para tarefas futuras:**
  - Quick Ratio v2, futuras curvas e novas métricas SaaS devem usar `var(--accent)` por default para a métrica principal e `var(--accent-strong)` ou `--cyan` para variações secundárias.
  - Se um logotipo Etiquetei oficial for definido, substituir o SVG inline do brand-mark (header e login) pelo asset real, mantendo o quadrado com gradient como container.
  - YoY pontilhada continua em `rgba(255,255,255,.25)` (neutra) — não precisa adaptar à paleta porque é "memória visual de comparação" e o accent teal já distingue a série principal.
  - Caso surja uma identidade visual completa (brandbook), revisar a paleta semântica também — hoje os semânticos seguem padrão Tailwind, suficientemente neutros.
