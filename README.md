 # Tópicos Avançados de Banco de Dados

## Índice

-  [Entregas](#entregas)
    - [Kick Off](#kick-off) - 28/02/2021 a 06/03/2021 
    - [Sprint 01](#sprint-01) – 08/03/2021 a 28/03/2021
    - [Sprint 02](#sprint-02) - 29/03/2021 a 18/04/2021
    - [Sprint 03](#sprint-03)  - 26/04/2021 a 16/05/2021
    - [Sprint 04](#sprint-04) - 17/05/2021 a 05/06/2021

## Equipe

- 👩‍💻 [Giovanna Xavier](https://https://github.com/giovannaxavierm/)
- 👨‍💻 [Hercules Pereira](https://github.com/herculespsilva/)
- 👩‍💻 [Leticia Macedo Prudente de Carvalho](https://www.linkedin.com/mwlite/in/leticia-macedo-prudente-de-carvalho-a0413416a/)
- 👨‍💻 [Sandro Toline](https://github.com/sandrotoline/)
- 👩‍💻 [Thaís Bitencourt de Meneses](https://www.linkedin.com/in/thaisbitencourt/)
- 👨‍💻 [Thiago Dias](https://github.com/ThiagoDisk/)
- 👨‍💻 [Yan Rodrigues de Azevedo](https://www.linkedin.com/in/yan-rodrigues/)
- 👨‍💻 [Victor Cardial](https://github.com/VictorCardial/)

### Matéria: Tópicos Avançados de Banco de Dados
### Professor: Eduardo Sakaue

### Problema:
Devido a Lei “Art. 1º Esta Lei dispõe sobre o tratamento de dados pessoais, inclusive nos meios digitais, por pessoa natural ou por pessoa jurídica de direito público ou privado, com o objetivo de proteger os direitos fundamentais de liberdade e de privacidade e o livre desenvolvimento da personalidade da pessoa natural.” que entrou em vigência em agosto de 2020, foi pedido para criarmos uma solução que resolva algum problema relacionado a lei.
O foco do grupo será na Gestão de consentimento do titular ou responsável (OptIn/OptOut), sendo esta pessoa física e no compartilhamento consciente de arquivos com dados de pessoais.

### Solução:
Desenvolver uma Plataforma que faz gestão de OptIn e OptOut e verifica a existência de dados pessoais em arquivos (TXT, Word e PDF), otimizando os atendimentos de LGPD;
Com acesso ao Banco de Dados de uma empresa (para desenvolver os testes iremos criar um banco de dados espelhado), colocaríamos as flags de OptIn e OptOut, considerando o período que o titular concedeu a utilização dos dados; 
Também iremos desenvolver uma ferramenta dentro desta plataforma web que irá realizar uma Varredura de Dados Pessoais (CPF, RG, Telefone, E-mail e Nome). A ferramenta recebe um arquivo e deve retornar de Forma Temporária os dados encontrados;
Realizaremos os testes com dados fictícios;
Também considerando ao que se refere a menores de idade, a Lei “O tratamento de dados pessoais de crianças deverá ser realizado com o consentimento específico e em destaque dado por pelo menos um dos pais ou pelo responsável legal.” iremos tratar em nosso projeto.

## Tecnologias Utilizadas

- Python: linguagem de programação de alto nível, interpretada de script, imperativa, orientada a objetos, funcional, de tipagem dinâmica e forte, além de fazer a correção de alocação de memória, gerenciamento de recursos, etc, automaticamente e eficiente permitindo que a concentração fosse exclusivamente no problema. Foi escolhida para desenvolver o validador de dados pessoais.
- Pandas: é uma biblioteca de software escrita para a linguagem de programação Python para manipulação e análise de dados, oferecendo estruturas e operações para manipular tabelas numéricas e séries temporais. Biblioteca Python escolhida para validar os dados pessoais por sua capacidade de simplificar tarefas complicadas de manipulação de dados.
- Flask e Flask Restfull: micro-framework multiplataforma que provê um modelo simples para o desenvolvimento web e que torna a aplicação muito mais leve e mais fácil de ser executada. Foi utilizado para desenvolver a API do validador de dados pessoais.
- SQL Server: sistema gerenciador de Banco de dados relacional, garantindo o suporte na recuperação dos dados, facilidade de uso e capacidade de melhor compreensão dos conjuntos de dados. Foi escolhido para desenvolver o banco de dados.



## Entregas

### Kick Off 
📅 *28/02/2021 a 06/03/2021*

- Definição das User Stories , Tasks e Tecnologias que serão utilizadas.

### Sprint 01 
📅 *08/03/2021 a 28/03/2021*

##### Banco de Dados SQL Server - Gestão de OptIn e OptOut - [DOCUMENTAÇÃO](https://github.com/ThaisBitencourt/Topicos-Avancados-em-Banco-de-Dados/blob/main/banco/sprint1/README.md) 

- Como proposta de solução para o problema mencionado acima, temos: Um modelo de Banco de Dados (SQLServer) teste chamado Northwind, juntamente com a implementação de políticas e segurança do tipo RLS (Row Level Security) e algumas alterações na tabela de dados cliente, como por exemplo, adição de um campo Flag na tabela para que seja possível registrar o atual estado de seu consentimento com relação aos tratamento de seus dados pessoais e uma tabela de histórico, contendo as datas de possíveis concessões e revogações do direito de manipular seus dados pessoais.

- Desenvolvimento do verificador em Python onde vemos a existência de dados pessoais(CPF, CNH, CNPJ, PIS, Titulo Eleitoral, CEP e Celular) em arquivos (TXT, Word e PDF), criamos uma API em Python que recebe o código e retorna através do Postman o dado encontrado.

[Código em Python - verificador](https://colab.research.google.com/drive/1b9PlOG9cYDp_cd26JIMdjrgcNfHsP8Bg#scrollTo=fZUsO84VZKNc)

[API - verificador](https://github.com/ThiagoDisk/APIPython)

### Sprint 02 
📅 *29/03/2021 a 18/04/2021*

- Consentimento de menores de idade: anexar autorização dos pais ou responsável legal ou documento comprovante de emancipação, feito no banco(flag menor de idade) - [DOCUMENTAÇÃO](https://github.com/ThaisBitencourt/Topicos-Avancados-em-Banco-de-Dados/blob/main/banco/sprint2/README.md)

- Integrar varredura com banco de dados (optout), iniciamos o desenvolvimento da Plataforma web integrando a Varredura de Dados Pessoais.

### Sprint 03 
📅 *26/04/2021 a 16/05/2021*

- Desenvolvimento da Plataforma web , integrar ferramenta de OptOut.

- Consentimento de menores de idade: integrar com a Plataforma Web, anexar autorização dos pais ou responsável legal ou documento comprovante de emancipação.

- Buscador e Validador de Nome

### Sprint 04
📅 *17/05/2021 a 05/06/2021*
- Verificar lista de disparo de e-mail marketing 

- Durante a varredura de dados pessoais, cruzar os dados com a flag de consentimento, para verificar documentos que não estão autorizados.


### Apresentação Final 
📅 *07/06/2021 a 11/06/2021*

### Feira de Soluções 
📅 *14/06/2021 a 18/06/2021*


