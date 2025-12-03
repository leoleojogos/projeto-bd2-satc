-- 2 - Quais os cinco mecânicos ativos com o maior número de ordens de serviço concluídas nos últimos 3 meses, considerando apenas serviços com valor superior a R$ 100?
-- Na tabela resultado, para cada um desses mecânicos, mostrar o nome completo, total de ordens, valor total faturado, e o tempo médio de conclusão.
-- Além disso, atribuir a cada mecânico uma categoria de produtividade (Alta, Média ou Baixa) baseando-se no número total de ordens concluídas.
    
-- Cria uma stored procedure
CREATE PROCEDURE sp_Top5MecanicosProdutivos
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DataReferencia DATE = '2025-12-01';
    
    -- Início da consulta principal que retorna os 5 mecânicos mais produtivos
    SELECT TOP 5
        
        m.nome AS [Nome Completo],
        COUNT(DISTINCT os.id_os) AS [Total de Ordens],
        'R$ ' + REPLACE(CONVERT(VARCHAR, CAST(
            -- ISNULL trata valores nulos como 0
            ISNULL(SUM(COALESCE(os_serv.valor_total, 0) + COALESCE(os_pec.valor_total, 0)), 0)
            AS DECIMAL(10,2)), 1), '.', ',') AS [Valor Total Faturado],

        CAST(
            ISNULL(AVG(
                CASE 
                    WHEN os.data_saida IS NOT NULL 
                    THEN DATEDIFF(DAY, os.data_entrada, os.data_saida)
                    ELSE 0 
                END
            ), 0) AS VARCHAR 
        ) + ' dias' AS [Tempo Médio de Conclusão],
        
        CASE 
            WHEN COUNT(DISTINCT os.id_os) >= 10 THEN 'Alta'
            WHEN COUNT(DISTINCT os.id_os) >= 5 THEN 'Média'
            ELSE 'Baixa'
        END AS [Categoria de Produtividade]

    FROM Mecanico m
    INNER JOIN OrdemServico os ON m.id_mecanico = os.id_mecanico
    INNER JOIN OS_Servico oss ON os.id_os = oss.id_os
    INNER JOIN Servico s ON oss.id_servico = s.id_servico
    
    LEFT JOIN (
        SELECT id_os, SUM(quantidade * valor_unitario) AS valor_total
        FROM OS_Servico
        GROUP BY id_os 
    ) os_serv ON os.id_os = os_serv.id_os
    
    LEFT JOIN (
        SELECT id_os, SUM(quantidade * valor_unitario) AS valor_total
        FROM OS_Peca
        GROUP BY id_os
    ) os_pec ON os.id_os = os_pec.id_os

    WHERE 
        m.ativo = 1

        AND os.data_entrada >= DATEADD(MONTH, -3, @DataReferencia)
        AND os.status = 'Concluída'
        AND s.valor_padrao > 100.00
        AND os.data_saida IS NOT NULL
        
    GROUP BY m.id_mecanico, m.nome
        
    HAVING COUNT(DISTINCT os.id_os) > 0

    ORDER BY 
        -- 1º critério: Mais ordens primeiro (decrescente)
        COUNT(DISTINCT os.id_os) DESC, 
        
        -- 2º critério: Em caso de empate, maior faturamento primeiro
        ISNULL(SUM(COALESCE(os_serv.valor_total, 0) + COALESCE(os_pec.valor_total, 0)), 0) DESC;
END;
GO

-- Executa a procedure
EXEC sp_Top5MecanicosProdutivos;
