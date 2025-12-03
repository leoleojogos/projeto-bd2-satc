-- 3 - Quais as cinco peças com maior valor total utilizado em ordens de serviço nos últimos 9 meses, considerando apenas peças com estoque acima do mínimo?
-- Na tabela resultado, para cada uma dessas peças, mostrar a descrição, fabricante, quantidade total utilizada, valor total gerado e valor médio por utilização.
-- Além disso, atribuir a cada peça um nível de rotatividade (Alta, Média ou Baixa) baseando-se na quantidade total utilizada.

ALTER PROCEDURE dbo.sp_relatorio_rotatividade_pecas
AS
BEGIN
SELECT TOP 5
p.id_servico AS descricao,
p.quantidade AS fabricante,
SUM(op.quantidade) AS quantidade_total_utilizada,
SUM(op.quantidade * op.valor_unitario) AS valor_total_gerado,
CAST(AVG(CAST(op.valor_unitario AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS valor_medio_por_utilizacao,
dbo.fn_classifica_rotatividade_peca(SUM(op.quantidade)) AS nivel_rotatividade
FROM peca p
JOIN os_peca op ON op.id_servico = p.id_peca
JOIN ordem_servico os ON os.id_os = op.id_os
WHERE os.data_entrada >= DATEADD(MONTH, -9, CAST(GETDATE() AS DATE))
AND p.estoque_atual > p.estoque_minimo
GROUP BY p.id_servico, p.quantidade
ORDER BY valor_total_gerado DESC;
END;
GO

-- Explicação geral:
-- A stored procedure sp_relatorio_rotatividade_pecas encapsula a lógica solicitada.
-- Ela consulta peças usadas nos últimos 9 meses, calcula total utilizado, valores financeiros e aplica a função fn_classifica_rotatividade_peca.
-- Procedures são usadas porque a pergunta exige a criação via ALTER PROCEDURE e porque centralizam a regra de consulta, facilitando manutenção e execução repetida.
