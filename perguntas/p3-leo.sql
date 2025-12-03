-- 3 - Quais as cinco peças com maior valor total utilizado em ordens de serviço nos últimos 9 meses, considerando apenas peças com estoque acima do mínimo?
-- Na tabela resultado, para cada uma dessas peças, mostrar a descrição, fabricante, quantidade total utilizada, valor total gerado e valor médio por utilização.
-- Além disso, atribuir a cada peça um nível de rotatividade (Alta, Média ou Baixa) baseando-se na quantidade total utilizada.


CREATE OR ALTER FUNCTION dbo.fn_classifica_rotatividade_peca (@qtd_total INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @nivel VARCHAR(20);

    
    IF (@qtd_total >= 50)
        SET @nivel = 'Alta';

    
    ELSE IF (@qtd_total >= 20)
        SET @nivel = 'Média';

    
    ELSE
        SET @nivel = 'Baixa';

   
    RETURN @nivel;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_relatorio_rotatividade_pecas
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensagens extras no resultado

    SELECT TOP 5
        p.descricao, -- Nome da peça
        p.fabricante, -- Fabricante da peça
        SUM(op.quantidade) AS quantidade_total_utilizada, -- Total usado em OS
        SUM(op.quantidade * op.valor_unitario) AS valor_total_gerado, -- Soma do valor utilizado
        AVG(op.valor_unitario) AS valor_medio_por_utilizacao, -- Média do valor unitário
        dbo.fn_classifica_rotatividade_peca(SUM(op.quantidade)) AS nivel_rotatividade -- Classificação via função
    FROM Peca p
    JOIN OS_Peca op ON op.id_peca = p.id_peca -- Peças utilizadas
    JOIN OrdemServico os ON os.id_os = op.id_os -- OS onde foram usadas
    WHERE os.data_entrada >= DATEADD(MONTH, -9, GETDATE()) -- Os últimos 9 meses
      AND p.estoque_atual > p.estoque_minimo -- Apenas peças com estoque seguro
    GROUP BY 
        p.id_peca,
        p.descricao,
        p.fabricante
    ORDER BY valor_total_gerado DESC;
END;
GO


-- Inserir peças para validar o relatório

INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (11, 11, 5, 250.00); 

INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (10, 9, 4, 120.00);   

INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (8, 21, 3, 300.00);  

INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (12, 5, 6, 150.00);  

INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (9, 18, 3, 180.00);  



EXEC dbo.sp_relatorio_rotatividade_pecas;



-- Explicação geral:
-- A função foi criada para encapsular a lógica de classificação da rotatividade de peças.
-- Ela foi centralizada na função fn_classifica_rotatividade_peca, que recebe o total utilizado e devolve a classificação (Alta, Média ou Baixa).
-- Procedure  gera um relatório das 5 peças mais utilizadas nos últimos 9 meses
-- Calcula quantidade total utilizada, valor total, valor médio e nível de rotatividade
