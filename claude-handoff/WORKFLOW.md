# Workflow

## Papeis

- Planner: cria specs em `specs/`, atualiza `specs/INDEX.md` e define criterios de aceite.
- Executor: le o spec, implementa, valida, preenche `Resultado da execução`, atualiza Obsidian, commita e abre PR.

O Claude Code normalmente atua como executor.

## Fluxo padrao

1. Atualizar estado local.

```bash
git fetch origin --prune
git switch main
git pull --ff-only
```

2. Criar branch de feature a partir de `main`.

```bash
git switch -c feat/<slug-da-tarefa>
```

3. Ler documentos obrigatorios.

```bash
cat CLAUDE.md
cat specs/<NNN-slug>.md
cat ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Projetos/Etiquetei/Dashboard/Implementação.md
```

4. Executar apenas o escopo do spec.

5. Rodar validacoes obrigatorias do spec.

6. Preencher a secao `Resultado da execução` no spec.

7. Atualizar Obsidian quando o resultado muda backlog/status.

8. Commitar e abrir PR.

```bash
git add <arquivos>
git commit -m "<tipo>: <descricao curta>"
git push -u origin feat/<slug-da-tarefa>
gh pr create --repo akliot/dashboard-etiquetei --base main --head feat/<slug-da-tarefa> --title "<titulo>" --body "<resumo>"
```

## Regras

- Nao fazer push direto para `main`.
- Nao misturar duas features no mesmo PR.
- Nao alterar backend/API/pipeline quando o spec for apenas frontend.
- Nao inventar classificacoes de dados. Se a base nao sustentar, parar e reportar.
- Nao apagar ou reverter mudancas do usuario.
- Se encontrar conflito entre spec e estado real do repo, parar e explicar.

## Validacoes base

Use sempre que `dashboard_bq.html` mudar:

```bash
python3 -m unittest test_pipeline.py test_api.py
python3 -c "import re; html=open('dashboard_bq.html').read(); scripts=re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL); open('/tmp/dashboard_etiquetei.js','w').write('\n'.join(scripts))"
node --check /tmp/dashboard_etiquetei.js
git diff --check
```

Use quando houver PRs/branches:

```bash
gh pr list --repo akliot/dashboard-etiquetei --state open --limit 10
git branch -vv
git log --oneline --decorate -10
```
