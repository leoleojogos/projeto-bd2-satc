

1 - Quais os três clientes com o maior número de veículos distintos que realizaram manutenções preventivas nos últimos 8 meses, por mecânicos com especialidade em "Motor"?
Na tabela resultado, para cada um desses três clientes, mostrar o nome completo, total de veículos, número total de manutenções preventivas, e o valor médio gasto por veículo.
Além disso, atribuir a cada cliente um nível de portfólio (Grande, Médio ou Pequeno) baseando-se no número total de veículos
    
-- Primeiro filtro todas as manutenções preventivas feitas por mecânicos de Motor
WITH manutencoes AS (
    SELECT 
        c.id_cliente,                -- pego o cliente dono do veículo
        v.id_veiculo,                -- identifico qual veículo fez a manutenção
        os.id_os,                    -- pego a ordem de serviço
        SUM(oss.quantidade * oss.valor_unitario) AS valor_total  -- calculo o valor gasto na OS
    FROM OrdemServico os
    JOIN Veiculo v ON v.id_veiculo = os.id_veiculo        -- ligo OS ao veículo
    JOIN Cliente c ON c.id_cliente = v.id_cliente         -- e o veículo ao cliente
    JOIN Mecanico m ON m.id_mecanico = os.id_mecanico     -- e identifico o mecânico que fez
    JOIN OS_Servico oss ON oss.id_os = os.id_os           -- pego os serviços feitos na OS
    JOIN Servico s ON s.id_servico = oss.id_servico       -- e a descrição dos serviços
    WHERE 
        m.especialidade = 'Motor'                         -- só mecânicos especializados em motor
        AND s.descricao ILIKE '%prevent%'                 -- serviços preventivos
        AND os.data_saida >= CURRENT_DATE - INTERVAL '8 MONTH'   -- últimos 8 meses
        AND os.status = 'Concluída'                       -- OS concluídas
    GROUP BY c.id_cliente, v.id_veiculo, os.id_os         -- agrupo para somar o valor da OS
),

-- Aqui faço os totais por cliente
agregado AS (
    SELECT
        id_cliente,
        COUNT(DISTINCT id_veiculo) AS total_veiculos,   -- quantos veículos diferentes o cliente trouxe
        COUNT(id_os) AS total_manutencoes,              -- quantas preventivas ele fez
        AVG(valor_total) AS valor_medio_por_veiculo     -- média de gasto por veículo
    FROM manutencoes
    GROUP BY id_cliente
),

-- Classifico o cliente conforme o número de veículos
classificado AS (
    SELECT 
        c.id_cliente,
        c.nome,
        a.total_veiculos,
        a.total_manutencoes,
        a.valor_medio_por_veiculo,
        CASE
            WHEN total_veiculos >= 10 THEN 'Grande'      -- muitos veículos
            WHEN total_veiculos BETWEEN 5 AND 9 THEN 'Médio'
            ELSE 'Pequeno'                              -- poucos veículos
        END AS nivel_portfolio
    FROM Cliente c
    JOIN agregado a ON a.id_cliente = c.id_cliente       -- junto com os totais calculados
)

-- Aqui pego só os 3 primeiros clientes
SELECT *
FROM classificado
ORDER BY total_veiculos DESC
LIMIT 3;
