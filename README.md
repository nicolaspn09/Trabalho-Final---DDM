# Trabalho Final DDM - Controle Financeiro Pessoal

**Tema:** Aplicativo de Gestão Financeira Pessoal

**Alunos:** Kauê Cunha Baesso, Nasser Nacim Levandoski Francisco, Nícolas Paulo Nasário.

## Descrição da Ideia
A ideia é desenvolver um aplicativo para ajudar as pessoas a gerenciarem suas finanças pessoais de forma simples e direta. 

O usuário poderá se cadastrar e se autenticar por e-mail e senha. Uma vez logado, ele terá acesso a um painel geral que mostra o saldo acumulado (calculado a partir da soma de receitas e subtração de despesas) e a lista das transações financeiras cadastradas.

Ao clicar no botão de adicionar, abre-se um formulário onde o usuário preenche os detalhes de uma nova movimentação:
* Título / Descrição da transação.
* Valor em reais.
* Tipo de transação (Entrada/Receita ou Saída/Despesa).
* Categoria (Ex: Alimentação, Transporte, Salário, Lazer).
* Data da transação.

## Protótipo das Telas
O protótipo das telas foi desenhado seguindo a navegação por rotas nomeadas:
1. **Tela de Login / Cadastro:** Entrada de e-mail e senha para acessar o aplicativo de forma protegida.
2. **Tela de Listagem (Inicial):** Exibe o saldo total disponível destacado em verde (se positivo) ou vermelho (se negativo), seguido por uma listagem de todas as movimentações financeiras. Possui opção de exclusão e logout.
3. **Tela de Formulário:** Campos de input estruturados para o cadastro de uma nova transação.
4. **Tela de Detalhes:** Exibe as informações detalhadas da transação selecionada na listagem (valor, data, categoria e tipo).
