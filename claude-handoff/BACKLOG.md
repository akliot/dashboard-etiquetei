# Backlog

Atualizado em: 2026-04-29

## Imediato

1. Mergear PR #4.

PR:

- `#4 feat: análise mensal de despesas de marketing`
- Branch: `feat/analise-marketing`
- Conteudo: spec 003, bloco de despesas de marketing na aba Resultado

2. Depois do merge, sincronizar `main` local.

```bash
git fetch origin --prune
git switch main
git pull --ff-only
```

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
