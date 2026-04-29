# Model Guide

## Para planejar specs

Use `GPT-5.4-codex medium` como padrao.

Suba para `GPT-5.5 medium` quando:

- houver muita ambiguidade de negocio;
- a tarefa depender de varios arquivos e Obsidian;
- for necessario decompor em meta-spec e specs filhos;
- uma especificacao errada puder gerar retrabalho caro.

## Para executar specs no Claude Code

Use o Claude Sonnet mais recente em `medium` para:

- ajustes HTML/JS;
- validacoes;
- specs bem delimitados;
- documentacao e PRs.

Use Opus ou modo mais forte para:

- refactors grandes;
- mudancas analiticas com varias abas;
- decisoes de UI/UX com alto risco de regressao visual;
- investigacoes que exigem ler muita base antes de editar.

## Regra pratica

Se o spec esta bem escrito e tem comandos de validacao, o executor nao precisa do modelo mais caro. O ganho vem de disciplina: ler o spec, manter escopo pequeno, validar e preencher resultado.
