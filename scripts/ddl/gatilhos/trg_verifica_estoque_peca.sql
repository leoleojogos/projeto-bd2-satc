CREATE TRIGGER trg_verifica_estoque_peca
ON OS_Peca
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Verifica se alguma inserção excede o estoque
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Peca p ON p.id_peca = i.id_peca
        WHERE i.quantidade > p.estoque_atual
    )
    BEGIN
        RAISERROR ('Erro: quantidade solicitada excede o estoque disponível da peça.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Se passou, insere normalmente
    INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario)
    SELECT id_os, id_peca, quantidade, valor_unitario
    FROM inserted;
END;
GO
