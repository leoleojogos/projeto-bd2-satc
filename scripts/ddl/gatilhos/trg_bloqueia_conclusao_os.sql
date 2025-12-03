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