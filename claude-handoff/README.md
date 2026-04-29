# Claude Handoff

Esta pasta concentra a documentação operacional para o Claude Code trabalhar no `dashboard-etiquetei`.

Use assim:

1. Leia `CURRENT_STATE.md` para entender o estado real do repo, branches e PRs.
2. Leia `WORKFLOW.md` para seguir o fluxo combinado de specs, branch e PR.
3. Leia `BACKLOG.md` para escolher a próxima frente.
4. Use `PROMPTS.md` para copiar comandos de handoff prontos.
5. Use `SPEC_TEMPLATE.md` quando uma nova tarefa precisar virar spec numerado em `../specs/`.

Separação de responsabilidades:

- `../CLAUDE.md`: referência curta do projeto e regras técnicas que não podem ser esquecidas.
- `../specs/`: tarefas executáveis numeradas, cada uma com resultado preenchido ao final.
- `claude-handoff/`: estado, fluxo, prompts e próximas decisões para coordenação.

Regra prática: se uma informação muda a cada rodada, ela provavelmente pertence aqui. Se é uma tarefa executável, pertence em `../specs/`.
