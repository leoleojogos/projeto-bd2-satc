2 - Quais os cinco mecânicos ativos com o maior número de ordens de serviço concluídas nos últimos 6 meses, considerando apenas serviços com valor superior a R$ 100?
Na tabela resultado, para cada um desses mecânicos, mostrar o nome completo, total de ordens, valor total faturado, e o tempo médio de conclusão.
Além disso, atribuir a cada mecânico uma categoria de produtividade (Alta, Média ou Baixa) baseando-se no número total de ordens concluídas.
    
-- Primeiro calculo as OS concluídas nos últimos 6 meses com valor acima de 100 reais
WITH ordens_validas AS (
    SELECT
        os.id_os,                                     -- identifico a OS
        os.id_mecanico,                               -- mecânico responsável
        SUM(oss.quantidade * oss.valor_unitario) AS valor_total, -- somo o valor da OS
        EXTRACT(EPOCH FROM (os.data_saida - os.data_entrada)) / 3600 AS horas_conclusao
            -- calculo o tempo que a OS demorou (em horas)
    FROM OrdemServico os
    JOIN Mecanico m ON m.id_mecanico = os.id_mecanico
    JOIN OS_Servico oss ON oss.id_os = os.id_os
    WHERE
        m.ativo = TRUE                               -- apenas mecânicos ativos
        AND os.status = 'Concluída'                  -- OS concluídas
        AND os.data_saida >= CURRENT_DATE - INTERVAL '6 MONTH'  -- últimos 6 meses
    GROUP BY os.id_os, os.id_mecanico, os.data_saida, os.data_entrada
    HAVING SUM(oss.quantidade * oss.valor_unitario) > 100  -- OS acima de 100 reais
),

-- Agora junto os totais por mecânico
agregado AS (
    SELECT
        m.id_mecanico,
        m.nome,
        COUNT(ov.id_os) AS total_ordens,                 -- quantas OS válidas ele concluiu
        SUM(ov.valor_total) AS valor_total_faturado,     -- quanto ele gerou de faturamento
        AVG(ov.horas_conclusao) AS tempo_medio_horas     -- tempo médio para concluir uma OS
    FROM Mecanico m
    JOIN ordens_validas ov ON ov.id_mecanico = m.id_mecanico
    GROUP BY m.id_mecanico, m.nome
),

-- Aqui classifico a produtividade do mecânico
classificado AS (
    SELECT *,
        CASE
            WHEN total_ordens >= 50 THEN 'Alta'          -- muito produtivo
            WHEN total_ordens BETWEEN 20 AND 49 THEN 'Média'
            ELSE 'Baixa'                                 -- menos produtivo
        END AS categoria_produtividade
    FROM agregado
)

-- E no final pego só os 5 melhores
SELECT *
FROM classificado
ORDER BY total_ordens DESC
LIMIT 5;
