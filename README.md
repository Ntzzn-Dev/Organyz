# organyz

**Projeto:** organyz  
**Autor:** Nathan  
**GitHub:** [https://github.com/Ntzzn-Dev](https://github.com/Ntzzn-Dev)  
**Data:** 07/05/2025  
**Natureza:** Flutter (Dart), focado em Android  

## Descrição  

Um aplicativo para Android que te permite fazer anotações e marcações importantes, com facilidade de exclusão pós finalização.  
Indicado para uma melhor organização de links ou tarefas importantes.  

## Log de versões  

### version 4.2  
- Adicionada forma de reposicionamento de elementos, tanto repositórios quanto itens internos.  

### version 5.0  
- Foram adicionadas a possibilidade de multilines nos títulos e descrições.  
- Alteração nos botões de criação, um novo botão de adição que engloba os 3 foi adicionado.  
- Sistema de filtragem de tipo de item.  
- Substituição dos 'x' por '_' em caixas de texto que são preenchidas.  

### version 6.0  
- Criação do contador.  
- Correção da criação de itens vazios.  
- Correção dos filtros, para evitar tamanho grande demais.  
- Atualização do itemList, onde não há mais o onPressedOpen para um botão pré-definido com ações diferentes, agora uma row com quantos itens ou botões for necessário.  

### version 6.1  
- Atualização do itemList, retirada de duas variáveis desnecessárias, adição de tipagem.  
- Criação do histórico de contagem, tanto para adição, subtração e reinício.  
- Correção para a edição e delete de um contador.  
- Mudança de mínimo e máximo mantendo o valor atual dentro do intervalo.  
- Otimização na classe repository.  
- Adição do popup do histórico.  
- Correção do horário das alterações na contagem para distâncias de tempo.  

### version 6.2  
- Criação da hierarquia de Tarefas, onde elas são marcadas em ordem crescente de acordo com a data final.  
- Correção da falta de mesclagem por diferenças em espaço.  
- Agora os botões de adição são fechados, se o usuário não usá-los.  

### version 6.3  
- Adição de um item no histórico sempre que criado um contador.  
- Edição do itemList sem necessidade de recarregar totalmente a árvore de widgets.  
- Troca da cor do número das contagens.  

### version 6.5  
- Adição da ordem escrita apenas visualmente.  
- Alteração da ordem escrita dos demais ao editar.  
- Troca da data pelo titulo no calendario.  

### version 7.0  
- Criação das quests no banco de dados para as tasks.  
- Reorganização dos elementos otimizada.  
- Salva temporariamente o estado sobre estar expandido ou não.  
- Criacao das etapas para a finalização da tarefa.  
- Visualização em porcentagem para tasks com quests.  

### version 7.1  
- Exclusão de quests individualmente.  
- Reordenação das quests consertado.  
- Edição direta do titulo e descrição das quests.  

### version 7.2  
- Correção da troca de estado manual de tasks.  
- Alteração do popup de listagem de informações.  
- Adição da visualização de quests da task clicada, por um popup.  
- Agora a cor do card de tasks que ja passaram da data limite mudam de cor para destacar.  