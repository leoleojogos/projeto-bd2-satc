
IF OBJECT_ID('sp_Top3MecanicosProdutivos', 'P') IS NOT NULL
    DROP PROCEDURE sp_Top3MecanicosProdutivos;
GO

CREATE PROCEDURE sp_Top3MecanicosProdutivos
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DataReferencia DATE = '2025-12-01';
    
    -- Consulta principal (agora TOP 3)
    SELECT TOP 3
        m.nome AS [Nome Completo],
        COUNT(DISTINCT os.id_os) AS [Total de Ordens],
        'R$ ' + REPLACE(CONVERT(VARCHAR, CAST(
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
        -- Categorias ajustadas para 3 mecânicos (mais realista)
        CASE 
            WHEN COUNT(DISTINCT os.id_os) >= 3 THEN 'Alta'
            WHEN COUNT(DISTINCT os.id_os) >= 2 THEN 'Média'
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
    WHERE m.ativo = 1
        -- Últimos 3 meses a partir da data de referência
        AND os.data_entrada >= DATEADD(MONTH, -3, @DataReferencia)
        AND os.status = 'Concluída'
        AND s.valor_padrao > 100.00
        AND os.data_saida IS NOT NULL
    GROUP BY m.id_mecanico, m.nome
    HAVING COUNT(DISTINCT os.id_os) > 0
    ORDER BY COUNT(DISTINCT os.id_os) DESC, 
             ISNULL(SUM(COALESCE(os_serv.valor_total, 0) + COALESCE(os_pec.valor_total, 0)), 0) DESC;
END;
GO