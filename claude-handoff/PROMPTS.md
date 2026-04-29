# Prompts

## Executar um spec

```text
Você vai executar uma tarefa a partir de um spec já escrito no projeto.

Projeto:
`/Users/antoinekmouawad/dashboard-etiquetei`

Sua função aqui é executor, não planner. Siga o spec, implemente apenas o que ele pede, valide e atualize a seção "Resultado da execução" ao final.

Primeiro passo:
1. Leia `CLAUDE.md`
2. Leia `claude-handoff/CURRENT_STATE.md`
3. Leia `claude-handoff/WORKFLOW.md`
4. Leia `specs/<NNN-slug>.md`
5. Leia também:
   `/Users/antoinekmouawad/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md`

Instruções:
- Siga o spec como fonte principal.
- Não improvise escopo novo.
- Se o estado real do repo divergir do spec, pare e explique.
- Se push direto para `main` estiver bloqueado, use branch de feature.
- Preencha a seção `Resultado da execução` no spec ao final.
- Atualize o Obsidian quando a tarefa for concluída, redefinida ou bloqueada.

Validação:
- Rode todos os comandos de validação do spec.
- Se `dashboard_bq.html` mudar, rode `python3 -m unittest test_pipeline.py test_api.py`, `node --check` no JS extraído e `git diff --check`.

Entrega:
- resumo curto do que mudou;
- arquivos alterados;
- validações executadas;
- commit realizado;
- branch/PR criado ou bloqueio encontrado.
```

## Atualizar main apos merges

```text
Os PRs foram mergeados em main.

Pode atualizar sua base:
- `git fetch origin --prune`
- `git switch main`
- `git pull --ff-only`

Depois confirme:
- HEAD atual da `main`
- PRs abertos restantes
- se ha mudanças locais
```

## Mergear PR via gh

```text
Pode mergear o PR indicado via `gh`, sem push direto para main.

Depois:
1. confirme que o PR ficou `MERGED`
2. confirme o novo HEAD de `origin/main`
3. atualize sua `main` local com `git fetch origin --prune && git switch main && git pull --ff-only`
4. devolva um resumo curto
```

## Criar proximo spec

```text
Crie o próximo spec numerado em `specs/`, seguindo `claude-handoff/SPEC_TEMPLATE.md`.

Antes:
- leia `claude-handoff/CURRENT_STATE.md`
- leia `claude-handoff/BACKLOG.md`
- verifique `specs/INDEX.md` para escolher o próximo número

Depois:
- atualize `specs/INDEX.md`
- não implemente código
- devolva o caminho do spec criado e o resumo do objetivo
```
