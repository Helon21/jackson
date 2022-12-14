(YAGO)01- Escreva quarto procedures de sintaxe - não precisa ter funcionalidade, basta não dar erro de sintaxe. Use variável global para testar.
- Faça uma declarando variáveis e com select into; 
- Faça a segunda com uma estrutura de decisão; 
- Faça a terceira que gere erro, impedindo a ação;
- Faça a quarta com if e else. 

![alt text](https://github.com/Helon21/jackson/blob/main/Listas/exercicio1.jpg)

(YAGO)02 - Escreva uma procedure que registre a baixa de um produto e já atualize devidamente o estoque do produto. Antes das ações, verifique se o produto é ativo.

![alt text](https://github.com/Helon21/jackson/blob/main/Listas/exercicio1.jpg)

(EDUARDO)03 - Escreva uma procedure que altere o preço de um produto vendido (venda já realizada - necessário verificar a existência da venda). Não permita alterações abusivas - preço de venda abaixo do preço de custo. É possível implementar esta funcionalidade sem a procedure? Se sim, indique como, bem como as vantagens e desvantagens.

(LUIS)04 - Escreva uma procedure que registre vendas de produtos e já defina o total da venda. É possível implementar a mesma funcionalidade por meio da trigger? Qual seria a diferença?

DROP PROCEDURE IF EXISTS insercao_ivenda_total;
DELIMITER //
CREATE PROCEDURE insercao_ivenda_total(id_produto INT, id_venda INT, quantidade INT, preco_unidade DECIMAL(8,2))
BEGIN
    DECLARE total_ivenda INT;
    INSERT INTO ivenda (produto_id,venda_id,quantidade,preco_unidade) VALUES 
    (id_produto, id_venda, quantidade, preco_unidade);
    SET total_item_venda = quantidade * preco_unidade;
    UPDATE venda SET total = total + total_ivenda WHERE venda.id = id_venda;
END;
//
DELIMITER ;

/*
	-- Sim, seria possível fazer por Trigger, a diferença seria que não seria mais necessário chamar a procedure,
    porém perderia-se a possibilidade de realizar a inserção sem passar pela trigger(a não ser que alguma condicional fosse estabelecida)
*/

(DA HORA)05- Para o controle de salário de funcionários de uma empresa e os respectivos adiantamentos (vales):
 - quais tabelas são necessárias?

(INDIVIDUAL)06- De acordo com o seu projeto de banco de dados, pense em pelo menos 3 procedures úteis. Discuta com os seus colegas em relação a relevância e implemente-as.

Luis - Função que insere aluno e já verifica se esse é maior de idade, passando para a coluna maior_idade que pode receber ‘S’ ou ‘N’. Nesse caso poderia ser resolvido também trigger ou passando como uma função para uma coluna virtual.
DELIMITER //
CREATE PROCEDURE insercao_aluno(nome VARCHAR(255), usuario VARCHAR(25), senha VARCHAR(25), cpf CHAR(14), email VARCHAR(25), telefone CHAR(14), endereco VARCHAR(255), cidade_id INT, data_nascimento DATE)
BEGIN
	DECLARE maior_idade CHAR(1);
	DECLARE ano_atual DATE;
    SET ano_atual = CURDATE();
	IF DATEDIFF(ano_atual, data_nascimento) > 6570 THEN -- Como essa função no MYSQL só retorna a diferença em dias converte-se os 18 anos para 6570 dias
		BEGIN
			SET maior_idade = 'S';
		END;
	ELSE
		BEGIN
			SET maior_idade = 'N';
		END;
	END IF;
    INSERT INTO aluno (nome, usuario, senha, cpf, email, telefone, endereco, cidade_id, maior_idade) VALUES
	(nome, usuario, senha, cpf, email, telefone, endereco, cidade_id, maior_idade);
END;
//
DELIMITER ;

Helon - Excluir clientes inativos

DELIMITER //
CREATE PROCEDURE cliente_inativo(id_cliente INT)
BEGIN
	DECLARE ativo CHAR;
	SELECT cliente.ativo INTO ativo FROM cliente WHERE cliente.id = id_cliente;
    IF ativo = 'N' THEN
		BEGIN
			DELETE cliente.id FROM cliente 
            WHERE cliente.id = id_cliente AND ativo = 'N';
		END;
    END IF;
END;
//
DELIMITER ;


(Helon)07- Explique as diferenças entre trigger, função e procedure. Indique as vantagens e desvantagens em utilizar a procedure.
R: Triggers(gatilhos) são blocos de comandos executados automaticamente, disparados por eventos determinados por nós.
A trigger está diretamente ligada à tabela. Pode ser usada para impedir alterações na tabela exibindo uma mensagem de erro. Por exemplo, caso queira realizar a exclusão do cadastro de algum cliente que tenha alguma pendência, é possível usar a trigger para bloquear a exclusão enquanto houver alguma pendência do cliente ou de seu cadastro.
As Triggers não possuem retorno.

Stored Procedure(Procedimento Armazenado) é um bloco de comandos ou instruções em SQL organizados para executar uma ou mais tarefas. Procedures aceitam um ou mais parâmetros de entrada para que a tarefa seja efetuada de acordo com a necessidade individual. E diferente das funções, as procedures não possuem um Retorno(RETURN), e também não precisam ser compiladas e executadas todas as vezes em que são chamadas. As procedures são pré-compiladas, assim sendo executadas somente na sua chamada.
As procedures são usadas para concentrar códigos, principalmente quando vamos utilizá-los mais de uma vez.

Vantagens da procedure: 1 - Melhor desempenho, são rápidas e eficientes, pois são compiladas uma vez e armazenadas na forma de executável, melhorando o tempo de resposta e reduzindo os requisitos de memória.

2 - Maior produtividade: O mesmo trecho de código é usado repetidamente.

3 - Facilidade de uso: Elas podem ser implantadas em qualquer camada de arquitetura de rede.

4 - Capacidade de manutenção: Manter um procedimento em um servidor é muito mais fácil do que manter cópias em várias máquinas de clientes, porque os scripts estão em um local.

Desvantagens:

1 - Teste: Teste de uma lógica encapsulada dentro de um procedimento armazenado é muito mais difícil. Quaisquer erros de dados no tratamento de procedimentos armazenados não são gerados até o tempo de execução

2 - Depuração: Dependendo da tecnologia de banco de dados, depurar procedimentos armazenados será muito mais dificil ou impossível. 

3 - Controle de versão: O controle de versão não é compatível com o procedimento armazenado.

4 - Custo: Um desenvolvedor extra na forma de DBA é necessário para acessar o SQL e escrever um procedimento armazenado melhor. Isso irá incorrer automaticamente em um custo adicional.

5 - Portabilidade - Procedimentos armazenados são complexos e nem sempre serão portados para versões atualizadas do mesmo banco de dados.

6 - Segurança: Diminui o risco de acesso ao banco de dados.


Funções podem aceitar parâmetros e efetuar cálculos lógicos e complexos, e diferente das procedures as funções possuem um retorno, elas podem retornar valores ou tabelas. As funções podem ser Escalares, que possuem um único valor, ou Table - Valued, que retornam um conjunto de resultados, uma tabela.
 */
