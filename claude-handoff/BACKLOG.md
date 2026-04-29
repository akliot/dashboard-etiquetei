# Backlog

Atualizado em: 2026-04-29

## Imediato

1. Mergear o PR de docs `docs/handoff-after-pr4` (atualizacao deste CURRENT_STATE/BACKLOG apos merge do PR #4). Sem urgencia tecnica; e housekeeping.

2. Depois disso, escolher a proxima tarefa recomendada (abaixo).

## Concluido recentemente

- PR #4 (`feat: análise mensal de despesas de marketing`) mergeado em `main` via merge commit `824a238` (mergedAt `2026-04-29T21:47:26Z`). O bloco de Marketing ja esta em producao (GitHub Pages atualiza no push para `main`).

## Proxima tarefa recomendada

Criar spec 004 para QA final pos-rebrand e pos-marketing.

Objetivo sugerido:

- Abrir o dashboard local/publicado e passar por todas as abas.
- Validar legibilidade da paleta teal, contraste, mobile/desktop e graficos novos.
- Confirmar que Resultado nao ficou pesado apos bloco de Marketing.
- Confirmar que YoY, Curva de Recuperacao, Quick Ratio e Marketing coexistem sem poluicao visual.

Nome sugerido:

- `004-qa-final-dashboard-pos-rebrand-e-marketing.md`

## Backlog analitico

Quick Ratio v2:

- Separar expansao e contracao.
- Bloqueio atual: nao ha historico confiavel de `valor_mensal` por contrato.
- Antes de implementar, criar discovery spec para investigar se Omie tem historico de alteracao contratual, snapshots ou logs suficientes.

Possivel spec futuro:

- `005-discovery-quick-ratio-v2-expansao-contracao.md`

## Backlog visual

Logo oficial Etiquetei:

- Hoje ha brand-mark SVG inline criado para o dashboard.
- Se surgir logo oficial, substituir o SVG inline mantendo container e dimensoes estaveis.

Possivel spec futuro:

- `006-substituir-brand-mark-por-logo-oficial-etiquetei.md`

## Backlog tecnico

Limpeza de branches remotas antigas:

- Depois que PRs ja mergeados estiverem ok, avaliar apagar branches remotas antigas.
- Nao e urgente; evitar apagar se ainda houver referencias em PRs/documentacao.

Docs:

- Manter `specs/INDEX.md` atualizado.
- Manter este handoff alinhado quando PRs mudarem de estado.
