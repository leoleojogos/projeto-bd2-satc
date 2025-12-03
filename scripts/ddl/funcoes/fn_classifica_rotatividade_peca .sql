

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
