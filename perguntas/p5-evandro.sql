
-- 6 - Implementar um sistema de validação que impeça a conclusão de Ordens de Serviço enquanto houver serviços pendentes de precificação, 
-- garantindo que todas as transações estejam devidamente registradas financeiramente antes do fechamento.


CREATE TRIGGER trg_bloqueia_conclusao_os
ON OrdemServico
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica se status foi atualizado
    IF UPDATE(status)
    BEGIN
        -- Se a OS foi marcada como concluída, mas há serviços sem valor_unitario, bloquear
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN OS_Servico oss ON oss.id_os = i.id_os
            WHERE i.status = 'Concluída'
              AND oss.valor_unitario IS NULL
        )
        BEGIN
            RAISERROR ('Erro: A OS não pode ser concluída pois existem serviços pendentes.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO


SELECT * FROM OrdemServico; --Escolher uma ordem de serviço


SELECT * FROM Servico; --Verificar quais Serviços existem


INSERT INTO OS_Servico (id_os, id_servico, quantidade, valor_unitario) --Inserir uma Ordem de Serviço pendente
VALUES (11, 1, 1, NULL);

UPDATE OrdemServico      --Tentar concluir a OS
SET status = 'Concluída'
WHERE id_os = 11;

--Consulta Serviços Pendentes

SELECT 
    os.id_os,
    c.nome AS nome_cliente,
    m.nome AS nome_mecanico,
    os.data_entrada,
    COUNT(oss.id_servico) AS servicos_pendentes
FROM OrdemServico os
JOIN Veiculo v ON v.id_veiculo = os.id_veiculo
JOIN Cliente c ON c.id_cliente = v.id_cliente
JOIN Mecanico m ON m.id_mecanico = os.id_mecanico
JOIN OS_Servico oss ON oss.id_os = os.id_os
WHERE oss.valor_unitario IS NULL
  AND os.data_entrada >= DATEADD(MONTH, -6, GETDATE())
GROUP BY 
    os.id_os, 
    c.nome, 
    m.nome, 
    os.data_entrada
ORDER BY os.data_entrada ASC;
