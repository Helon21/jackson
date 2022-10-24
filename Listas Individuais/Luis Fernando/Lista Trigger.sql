-- 01- Escreva quatro triggers de sintaxe - a trigger não precisa ter funcionalidade, basta não dar erro de sintaxe. Use variável global para testar.
-- - Faça uma declarando variáveis e com select into; 
DROP TRIGGER IF EXISTS exemplo_select_into;

SET @teste = 'teste123';

DELIMITER //
CREATE TRIGGER exemplo_select_into
AFTER INSERT ON item_venda
FOR EACH ROW 
BEGIN
	SELECT nome INTO @teste FROM produto WHERE id = 1;
END;
//
DELIMITER ;

INSERT INTO item_venda(produto_id, venda_id, quantidade, preco_unidade) VALUES (1,1,3,10);
SELECT @teste;
-- - Faça a segunda com uma estrutura de decisão; 
DROP TRIGGER IF EXISTS exemplo_if;

SET @testeif = 'testando';

DELIMITER //
CREATE TRIGGER exemplo_if
AFTER INSERT ON item_venda
FOR EACH ROW 
BEGIN
	IF (1+1) = 2 THEN
		BEGIN
			SET @testif = TRUE;
		END;
	END IF;
END;
//
DELIMITER ;

INSERT INTO item_venda(produto_id, venda_id, quantidade, preco_unidade) VALUES (1,1,3,10);
SELECT @testeif;
-- - Faça a terceira que gere erro, impedindo a ação;
DROP TRIGGER IF EXISTS exemplo_erro;

SET @testeif = 'testando';

DELIMITER //
CREATE TRIGGER exemplo_erro
AFTER INSERT ON item_venda
FOR EACH ROW 
BEGIN
	IF (curdate()>'2022-10-23') THEN
		BEGIN
			SET @testerro = CURDATE();
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO, PASSOU DA DATA LIMITE DAS INSERÇÕES';
        END;
	END IF;
END;
//
DELIMITER ;

INSERT INTO item_venda(produto_id, venda_id, quantidade, preco_unidade) VALUES (1,1,3,10);
SELECT @testeerro;
-- - Faça a quarta que utilize a variável new e old - tente diferenciar. 
DROP TRIGGER IF EXISTS exemplo_erro;

SET @nomeantigo = '';
SET @nomenovo = '';

DELIMITER //
CREATE TRIGGER exemplo_erro
AFTER UPDATE ON produto
FOR EACH ROW 
BEGIN
	BEGIN
		SET  @nomeantigo = OLD.nome;
		SET  @nomenovo = NEW.nome;
	END;
END;
//
DELIMITER ;

UPDATE produto SET nome = 'Sucrilhos' WHERE produto.id = 1;
SELECT @nomeantigo;
SELECT @nomenovo;

-- 02- Uma trigger que tem a função adicionar a entrada de produtos no estoque deve ser associado para qual:
-- •	Tabela?
-- ICompra
-- •	Tempo?
-- AFTER
-- •	Evento?
-- INSERT
-- •	Precisa de variáveis? Quais?
-- Sim, quantidade.
-- •	Implemente a trigger. 


-- 03- Uma trigger que tem a função criar um registro de auditoria quando um pagamento e recebimento for alterada deve ser associado para qual(is):
-- •	Tabela(s)?
-- PAGAMENTO E RECEBIMENTO
-- •	Tempo?
-- AFTER
-- •	Evento?
-- UPDATE
-- •	Implemente a trigger (pode criar a tabela de auditoria)
CREATE TABLE auditoria(
	id INT NOT NULL AUTO_INCREMENT,
    pagamento_id INT,
    recebimento_id INT,
    data_alteracao DATETIME,
    valores_antigos VARCHAR (2500),
    valores_novos VARCHAR (2500)
    ,CONSTRAINT fk_pagamento FOREIGN KEY (pagamento_id) REFERENCES pagamento(id)
    ,CONSTRAINT fk_recebimento FOREIGN KEY (recebimento_id) REFERENCES recebimento(id)
);

DELIMITER // 
CREATE TRIGGER auditoria_pagamento
AFTER UPDATE ON pagamento
FOR EACH ROW
    BEGIN 
		INSERT INTO auditoria(pagamento_id,data_alteracao, valores_antigos, valores_novos)
        VALUES (id, NOW(), 
                CONCAT(OLD.data_cadastro, '-', OLD.valor, '-', OLD.descricao), 
                CONCAT(NEW.data_cadastro, '-', NEW.valor, '-', NEW.descricao));
    END;
// DELIMITER ;

DELIMITER // 
CREATE TRIGGER auditoria_recebimento 
AFTER UPDATE ON recebimento 
FOR EACH ROW 
    BEGIN 
        INSERT INTO auditoria(recebimento_id,data_alteracao, valores_antigos, valores_novos)
        VALUES (id, NOW(), 
                CONCAT(OLD.data_cadastro, '-', OLD.valor, '-', OLD.descricao ), 
                CONCAT(NEW.data_cadastro, '-', NEW.valor, '-', NEW.descricao ));
    END;
// 
DELIMITER ;

-- 04- Uma trigger que tem a função impedir a venda de um produto inferior a 50% do preço de venda deve ser associado para qual:
-- •	Tabela?
-- IVENDA;
-- •	Tempo?
-- BEFORE
-- •	Evento?
-- INSERT
-- •	Implemente a trigger

-- 05- Este é para testar a sintaxe - tente implementar sem o script
-- Uma trigger que tem a função de gerar o RA automático na tabela ALUNO deve ser associada para qual
-- •	Tabela?
-- ALUNO
-- •	Tempo?
-- AFTER
-- •	Evento?
-- INSERT
-- •	Precisa de variáveis? Quais?
-- RA
-- •	Implemente a trigger - RA igual a concatenção do ano corrente, código do curso e o id do cadastro do aluno. 

-- 06- De acordo com o seu projeto de banco de dados, pense em pelo menos 3 trigger úteis. Discuta com os seus colegas em relação a relevância e implemente-as.