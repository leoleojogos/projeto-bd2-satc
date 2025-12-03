
IF OBJECT_ID('fn_Top3ClientesManutencoes', 'TF') IS NOT NULL
    DROP FUNCTION fn_Top3ClientesManutencoes;
GO

CREATE FUNCTION fn_Top3ClientesManutencoes()
RETURNS TABLE
AS
RETURN 
(
    -- Seleciona os 3 primeiros clientes (TOP 3) que mais fizeram manutenções
    SELECT TOP 3
    
        c.nome AS [Nome Completo],
        COUNT(DISTINCT v.id_veiculo) AS [Total de Veículos],
        COUNT(DISTINCT os.id_os) AS [Número Total de Manutenções Preventivas],
        
        -- Calcula o valor médio gasto por veículo:
        CAST(
            CASE 
                WHEN COUNT(DISTINCT v.id_veiculo) > 0 
                -- Soma: valor total dos serviços + valor total das peças
                -- Divide pelo número de veículos para obter a média
                THEN SUM(COALESCE(os_serv.valor_total, 0) + COALESCE(os_pec.valor_total, 0)) / COUNT(DISTINCT v.id_veiculo)
                ELSE 0
            END AS DECIMAL(10,2)
        ) AS [Valor Médio Gasto por Veículo],
        
        COUNT(DISTINCT m.especialidade) AS [Especialidades Diferentes Utilizadas],
        
        -- Classifica o portfólio do cliente baseado no número de veículos:
        CASE 
            WHEN COUNT(DISTINCT v.id_veiculo) >= 5 THEN 'Grande'     
            WHEN COUNT(DISTINCT v.id_veiculo) >= 3 THEN 'Médio'     
            ELSE 'Pequeno'
        END AS [Nível de Portfólio]
    
    FROM Cliente c
    INNER JOIN Veiculo v ON c.id_cliente = v.id_cliente
    INNER JOIN OrdemServico os ON v.id_veiculo = os.id_veiculo
    INNER JOIN Mecanico m ON os.id_mecanico = m.id_mecanico
    INNER JOIN OS_Servico oss ON os.id_os = oss.id_os
    INNER JOIN Servico s ON oss.id_servico = s.id_servico
    
    LEFT JOIN (
        SELECT 
            id_os,
            SUM(quantidade * valor_unitario) AS valor_total
        FROM OS_Servico
        GROUP BY id_os 
    ) os_serv ON os.id_os = os_serv.id_os
    
    LEFT JOIN (
        SELECT 
            id_os,
            SUM(quantidade * valor_unitario) AS valor_total
        FROM OS_Peca
        GROUP BY id_os
    ) os_pec ON os.id_os = os_pec.id_os

    WHERE 
        m.especialidade IN ('Motor e Transmissão', 'Suspensão e Freios')
        AND os.data_entrada >= DATEADD(MONTH, -5, '2025-12-01')
        AND os.status = 'Concluída'
        AND s.descricao IN (
            'Troca de Óleo e Filtro',           
            'Alinhamento e Balanceamento',     
            'Troca de Pastilhas de Freio',     
            'Reparo na Suspensão'              
        )
    
    GROUP BY c.id_cliente, c.nome
    HAVING COUNT(DISTINCT os.id_os) > 0
    ORDER BY 
        COUNT(DISTINCT os.id_os) DESC,  
        SUM(COALESCE(os_serv.valor_total, 0) + COALESCE(os_pec.valor_total, 0)) DESC  
)
GO
