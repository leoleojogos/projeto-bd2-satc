-- Função criada para classificar a rotatividade de uma peça
-- Recebe a quantidade total utilizada e devolve: Alta, Média ou Baixa
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




-- Procedure que gera um relatório das 5 peças mais utilizadas nos últimos 9 meses
-- Calcula quantidade total utilizada, valor total, valor médio e nível de rotatividade
CREATE OR ALTER PROCEDURE dbo.sp_relatorio_rotatividade_pecas
AS
BEGIN
    SET NOCOUNT ON; -- Evita mensagens extras no resultado

    SELECT TOP 5
        p.descricao, 
        p.fabricante,
        SUM(op.quantidade) AS quantidade_total_utilizada, -- 
        SUM(op.quantidade * op.valor_unitario) AS valor_total_gerado, 
        AVG(op.valor_unitario) AS valor_medio_por_utilizacao, 
        dbo.fn_classifica_rotatividade_peca(SUM(op.quantidade)) AS nivel_rotatividade 
    FROM Peca p
    JOIN OS_Peca op ON op.id_peca = p.id_peca 
    JOIN OrdemServico os ON os.id_os = op.id_os
    WHERE os.data_entrada >= DATEADD(MONTH, -9, GETDATE()) 
      AND p.estoque_atual > p.estoque_minimo 
    GROUP BY 
        p.id_peca,
        p.descricao,
        p.fabricante
    ORDER BY valor_total_gerado DESC;
END;
GO


-- Inserir peças para validar o relatório
INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (11, 11, 3, 250.00);


INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (10, 9, 5, 120.00);


INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
VALUES (8, 21, 2, 300.00);


EXEC dbo.sp_relatorio_rotatividade_pecas;
