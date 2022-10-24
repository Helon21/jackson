-- Luis Fernando Brasil

-- 01- Escreva quarto procedures de sintaxe - não precisa ter funcionalidade, basta não dar erro de sintaxe. Use variável global para testar.
-- - Faça uma declarando variáveis e com select into; 
DELIMITER //
CREATE PROCEDURE verifica_preco_venda (id_produto INT)
BEGIN
    DECLARE preco DECIMAL(10,2);
    SELECT produto.preco_venda INTO preco FROM produto WHERE produto.id = id_produto;
END;
//
DELIMITER ;
-- - Faça a segunda com uma estrutura de decisão; 
SET @ativo = 'O Registro está ativo';

DELIMITER //
CREATE PROCEDURE verifica_cliente_ativo (id_cliente INT)
BEGIN
    DECLARE ativo CHAR;
    SELECT cliente.ativo INTO ativo FROM cliente WHERE cliente.id = id_cliente;
    IF ativo = 'S' THEN
		BEGIN
			SELECT @ativo;
		END;
    END IF;
END;
//
DELIMITER ;
-- - Faça a terceira que gere erro, impedindo a ação;
DELIMITER //
CREATE PROCEDURE delete_cliente (id_cliente INT)
BEGIN
    DECLARE ativo CHAR;
    SELECT cliente.ativo INTO ativo FROM cliente WHERE cliente.id = id_cliente;
    IF ativo = 'S' THEN
		BEGIN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CLIENTE ATIVO, NÃO PODE SER EXCLUÍDO';
		END;
    END IF;
    DELETE FROM cliente WHERE cliente.id = id_cliente;
END;
//
DELIMITER ;
-- - Faça a quarta com if e else. 
DELIMITER //
CREATE PROCEDURE insere_item_venda (id_produto INT)
BEGIN
    DECLARE estoque INT;
    SELECT produto.estoque INTO estoque FROM produto WHERE produto.id = id_produto;
    IF estoque>0 THEN
		BEGIN
			INSERT INTO ivenda(produto_id) VALUES (id_produto);
		END;
    ELSE
		BEGIN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ESTOQUE INSUFICIENTE';
        END;
    END IF;
END;
//
DELIMITER ;
-- 02 - Escreva uma procedure que registre a baixa de um produto e já atualize devidamente o estoque do produto. Antes das ações, verifique se o produto é ativo.
DELIMITER //
CREATE PROCEDURE insercao_baixa_produto(id_produto INT, id_funcionario INT, quantidade INT, descricao VARCHAR(100))
BEGIN
	DECLARE ativo CHAR;
    SELECT ativo FROM produto WHERE produto.id = id_produto;
    IF ativo = 'S' THEN
		BEGIN
			INSERT INTO BAIXA_PRODUTO (produto_id, id_funcionario, quantidade, descricao) VALUES 
			(id_produto, id_funcionario, quantidade, descricao);
			UPDATE produto SET estoque = (estoque - quantidade) WHERE produto.id = id_produto;
        END;
	END IF;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRODUTO INATIVO';
END;
//
DELIMITER ;
-- 03 - Escreva uma procedure que altere o preço de um produto vendido (venda já realizada - necessário verificar a existência da venda). Não permita altearções abusivas - preço de venda abaixo do preço de custo. É possível implementar esta funcionalidade sem a procedure? Se sim, indique como, bem como as vantagens e desvantagens.
DELIMITER //
CREATE PROCEDURE alterar_preco_produto(id_produto INT,id_venda INT, preco DECIMAL(10,2))
BEGIN
	DECLARE preco_custo DECIMAL(10,2);
    DECLARE venda_existe BOOL DEFAULT FALSE;
	SELECT preco_custo INTO preco_custo FROM produto WHERE produto.id = id_produto;
    SELECT (
		SELECT COUNT(*) 
        FROM venda 
        WHERE id = id_venda
	) = 1 INTO venda_existe;
    IF venda_existe THEN
		BEGIN
			IF preco > preco_custo THEN
				BEGIN
					UPDATE item_venda SET preco_unidade = preco WHERE item_venda.venda_id;
                END;
			ELSE
				BEGIN
					 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NOVO PREÇO NÃO PODE SER ABAIXO DO PREÇO DE CUSTO';
                END;
			END IF;
        END;
	ELSE
		BEGIN
			 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VENDA INEXISTENTE';
        END;
	END IF;
END;
//
DELIMITER ;

-- 04 - Escreva uma procedure que registre vendas de produtos e já defina o total da venda. É possível implementar a mesma funcionalidade por meio da trigger? Qual seria a diferença?
DELIMITER // 
CREATE PROCEDURE inserir_venda_total(id_venda INT, id_produto INT, preco_unidade INT, quantidade INT)
BEGIN 
    DECLARE total_venda DECIMAL(10,2);
    SET total_venda = preco_unidade * quantidade;
	INSERT INTO ivenda(venda_id, produto_id, preco_unidade, quantidade) VALUES (id_venda, id_produto, preco_unidade, quantidade);
    UPDATE venda SET total = total + total_venda WHERE venda.id = id_venda;
END;
//
DELIMITER ;
-- 05 - Para o controle de salário de funcionários de uma empresa e os respectivos adiantamentos (vales):
-- - quais tabelas são necessárias?
-- Será necessário a tabela de funcionário, salário e adiantamentos.	

-- 06- De acordo com o seu projeto de banco de dados, pense em pelo menos 3 procedures úteis. Discuta com os seus colegas em relação a relevância e implemente-as.

-- Procedure que deleta os cursos com mais de um ano desde sua criação que não possui nenhum aluno inscrito, essa função é um simples update mas demonstra uma aplicação de uma chamada de procedure que é mais intuitivo e menor que o código do update;  
DELIMITER //
CREATE PROCEDURE inativa_cursos_antigos()
BEGIN
	UPDATE curso SET status = 'Inativo' WHERE (numero_inscritos < 1) AND DATEDIFF(ano_atual, data_cadastro) > 365;
END;
//
DELIMITER ;

-- Procedure que deleta um professor mas antes verifica se este não tem algum curso ativo.
DELIMITER //
CREATE PROCEDURE deleta_professor(id_professor INT)
BEGIN
	DECLARE status_curso CHAR;
	DECLARE cursor_curso CURSOR FOR 
	SELECT 
		curso.status
		INTO status_curso FROM curso
    INNER JOIN curso_professor ON curso_professor.curso_id = curso.id
	INNER JOIN professor ON professor.id = curso_professor.professor_id
    WHERE professor.id = id_professor;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET acabou = TRUE;
	OPEN cursor_curso;
    read_loop : LOOP 
	FETCH cursor_curso INTO codigo_curso;
        IF status_curso = 'Ativo' THEN 
			BEGIN	
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O PROFESSOR NÃO PODE SER EXCLUÍDO POIS POSSUI CURSOS ATIVOS!';
			END;
		END IF;
        IF acabou THEN
			BEGIN
				LEAVE read_loop;
			END;
        END IF;
    END LOOP;
    CLOSE cursor_curso;
	DELETE FROM professor WHERE professor.id = id_professor;
END;
//
DELIMITER ;

-- Procedure que insere aluno e já verifica se esse é maior de idade, passando para a coluna maior_idade que pode receber ‘S’ ou ‘N’. Nesse caso poderia ser resolvido também trigger ou passando como uma função para uma coluna virtual.
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


-- 07- Explique as diferenças entre trigger, função e procedure. Indique as vantagens e desvantagens em utilizar a procedure.
/* Triggers(gatilhos) são blocos de comandos executados automaticamente, disparados por eventos determinados por nós.
A trigger está diretamente ligada à tabela. Pode ser usada para impedir alterações na tabela exibindo uma mensagem de erro. Por exemplo, caso queira realizar a exclusão do cadastro de algum cliente que tenha alguma pendência, é possível usar a trigger para bloquear a exclusão enquanto houver alguma pendência do cliente ou de seu cadastro.
As Triggers não possuem retorno.

Stored Procedure(Procedimento Armazenado) é um bloco de comandos ou instruções em SQL organizados para executar uma ou mais tarefas. Procedures aceitam um ou mais parâmetros de entrada para que a tarefa seja efetuada de acordo com a necessidade individual. E diferente das funções, as procedures não possuem um Retorno(RETURN), e também não precisam ser compiladas e executadas todas as vezes em que são chamadas. As procedures são pré-compiladas, assim sendo executadas somente na sua chamada.
As procedures são usadas para concentrar códigos, principalmente quando vamos utilizá-los mais de uma vez.

Vantagens da procedure: 
1 - Melhor desempenho, são rápidas e eficientes, pois são compiladas uma vez e armazenadas na forma de executável, melhorando o tempo de resposta e reduzindo os requisitos de memória.

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

