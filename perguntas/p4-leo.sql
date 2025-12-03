-- 4 - Quais os clientes com a maior frequência de manutenções corretivas nos últimos 18 meses, considerando veículos com mais de 3 anos e mecânicos com especialidade em "Suspensão" ou "Freios"?
-- Na tabela resultado, para cada um desses clientes, mostrar: nome completo, quantidade total de veículos, número de manutenções corretivas, valor total gasto em correções, tempo médio entre manutenções (em dias), e o veículo que mais demandou reparos.
-- Além disso, classificar cada cliente em uma categoria de criticidade (Alta, Média ou Baixa) baseando-se na combinação do valor gasto e frequência das manutenções.

ALTER FUNCTION dbo.fn_classifica_criticidade_cliente (
    @QtdManutencoes INT,
    @ValorTotal DECIMAL(18,2)
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @Nivel VARCHAR(10);
    
    IF (@QtdManutencoes >= 10 OR @ValorTotal >= 10000)
        SET @Nivel = 'Alta';
    ELSE IF (@QtdManutencoes >= 5 OR @ValorTotal >= 5000)
        SET @Nivel = 'Média';
    ELSE
        SET @Nivel = 'Baixa';
    
    RETURN @Nivel;
END;
GO

WITH ManutencoesCorretivas AS (
    SELECT
        c.id_cliente,
        c.nome AS nome_cliente,
        v.id_veiculo,
        os.id_os,
        os.data_entrada,
        SUM(osv.quantidade * osv.valor_unitario) AS valor_os
    FROM cliente c
    JOIN veiculo v ON v.id_cliente = c.id_cliente
    JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
    JOIN mecanico m ON m.id_mecanico = os.id_mecanico
    JOIN os_servico osv ON osv.id_os = os.id_os
    JOIN servico s ON s.id_servico = osv.id_servico
    WHERE os.data_entrada >= DATEADD(MONTH, -18, CAST(GETDATE() AS DATE))
        AND (YEAR(GETDATE()) - v.ano) > 3
        AND m.especialidade IN ('Suspensão', 'Freios')
        AND s.descricao LIKE '%corretiv%'
    GROUP BY c.id_cliente, c.nome, v.id_veiculo, os.id_os, os.data_entrada
),
ResumoCliente AS (
    SELECT
        id_cliente,
        nome_cliente,
        COUNT(DISTINCT id_veiculo) AS qtd_veiculos,
        COUNT(id_os) AS qtd_manutencoes,
        SUM(valor_os) AS valor_total_gasto,
        MIN(data_entrada) AS primeira_manutencao,
        MAX(data_entrada) AS ultima_manutencao
    FROM ManutencoesCorretivas
    GROUP BY id_cliente, nome_cliente
),
TempoMedio AS (
    SELECT
        id_cliente,
        nome_cliente,
        qtd_veiculos,
        qtd_manutencoes,
        valor_total_gasto,
        CASE
            WHEN qtd_manutencoes > 1 THEN
                DATEDIFF(DAY, primeira_manutencao, ultima_manutencao) / (qtd_manutencoes - 1)
            ELSE NULL
        END AS tempo_medio_entre_manutencoes
    FROM ResumoCliente
),
VeiculoMaisReparos AS (
    SELECT
        mc.id_cliente,
        mc.id_veiculo,
        COUNT(mc.id_os) AS qtd_manutencoes_veiculo,
        ROW_NUMBER() OVER (
            PARTITION BY mc.id_cliente 
            ORDER BY COUNT(mc.id_os) DESC
        ) AS rn
    FROM ManutencoesCorretivas mc
    GROUP BY mc.id_cliente, mc.id_veiculo
)
SELECT
    t.nome_cliente AS nome_completo,
    t.qtd_veiculos AS quantidade_total_veiculos,
    t.qtd_manutencoes AS numero_manutencoes_corretivas,
    t.valor_total_gasto,
    t.tempo_medio_entre_manutencoes,
    vmr.id_veiculo AS veiculo_mais_demandou_reparos,
    dbo.fn_classifica_criticidade_cliente(t.qtd_manutencoes, t.valor_total_gasto) AS criticidade
FROM TempoMedio t
JOIN VeiculoMaisReparos vmr
    ON vmr.id_cliente = t.id_cliente 
    AND vmr.rn = 1
ORDER BY 
    t.qtd_manutencoes DESC, 
    t.valor_total_gasto DESC;
GO

-- Explicação geral:
-- A função fn_classifica_criticidade_cliente foi criada usando ALTER FUNCTION
-- Ela classifica automaticamente clientes conforme gasto e quantidade de manutenções.
-- A função é usada na seleção final, fornecendo o nível de criticidade.
