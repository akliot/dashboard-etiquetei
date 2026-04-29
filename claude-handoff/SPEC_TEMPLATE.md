# Spec Template

Use este template ao criar novas tarefas em `../specs/`.

Nome do arquivo:

```text
NNN-slug-descritivo.md
```

Template:

```markdown
# NNN - [Título descritivo]

## Objetivo
[O quê e por quê, em 2-3 frases. Foco no resultado de negócio, não na implementação.]

## Contexto
[Estado atual relevante: arquivos em jogo, integrações, decisões anteriores que importam para esta tarefa.]

## Inputs
- [Arquivos, dados, credenciais, parâmetros que a tarefa consome]
- [Caminhos absolutos ou relativos à raiz do projeto, quando aplicável]

## Outputs esperados
- [Arquivos novos ou modificados, com caminhos]
- [Comportamento observável: "script roda sem erro", "dashboard mostra X", "linha Y aparece no log"]

## Suposições explícitas
- [Tudo que você está assumindo sobre o ambiente: versões de Python/Node, libs instaladas, formato dos dados de entrada, credenciais já configuradas, etc.]
- **Regra:** se uma suposição estiver errada, o executor deve PARAR e perguntar, não improvisar.

## Restrições
- [O que NÃO tocar: pastas, arquivos, sistemas, dados de outros clientes]
- [Limites de ação: "não fazer chamadas pagas de API", "não commitar", "não rodar em produção"]

## Passos sugeridos
1. [Decomposição em passos pequenos e verificáveis]
2. [Cada passo deve ter um critério claro de "pronto"]

## Critérios de aceite
- [ ] [Checks objetivos que provam que a tarefa foi concluída]
- [ ] [Inclua validações concretas, não vagas]

## Comandos de validação
```bash
# Comandos que o executor deve rodar para confirmar que funcionou
```

## Edge cases a considerar
- [Cenários que podem quebrar a implementação e como tratá-los]

---

## Resultado da execução
_Seção preenchida pelo executor (Claude Code) após rodar a tarefa. Não preencher no momento do planejamento._

- **Status:** pendente
- **Data de execução:** 
- **O que rodou com sucesso:** 
- **O que falhou ou ficou pendente:** 
- **Desvios do plano original (e por quê):** 
- **Observações para tarefas futuras:** 
```
