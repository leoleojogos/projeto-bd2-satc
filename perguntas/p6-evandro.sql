-- 6 - Implementar um controle de estoque que valide a disponibilidade de peças em tempo real durante o processo de venda,
-- prevenindo alocações acima do disponível e gerando relatórios preditivos de reposição.

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

SELECT id_peca, descricao, estoque_atual -- Escolher uma peça
FROM Peca
ORDER BY estoque_atual ASC;


SELECT id_os, status					-- Escolher uma OS em aberto
FROM OrdemServico
WHERE status <> 'Concluída';


INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario) -- Tentar inserir uma peça alem do limite "quantidade" - Inserção Invalida
VALUES (11, 11, 9, 150.00);


INSERT INTO OS_Peca (id_os, id_peca, quantidade, valor_unitario) -- Tentar inseri uma peça dentro do limite "quantidade" - Inserção Válida
VALUES (11, 11, 5, 150.00);


SELECT * FROM OS_Peca WHERE id_os = 11; 


--CONSULTA — Gera um relatório que mostra peças em risco de faltar (Opicional)

SELECT 
    p.id_peca,
    p.descricao,
    p.fabricante,
    p.estoque_atual,
    SUM(op.quantidade) AS total_solicitado,
    (p.estoque_atual - SUM(op.quantidade)) AS saldo_estoque,
    CASE
        WHEN (p.estoque_atual - SUM(op.quantidade)) < 0 THEN 'Estoque Insuficiente'
        WHEN (p.estoque_atual - SUM(op.quantidade)) <= 5 THEN 'Crítico'
        ELSE 'Adequado'
    END AS status_estoque
FROM Peca p
JOIN OS_Peca op ON op.id_peca = p.id_peca
JOIN OrdemServico os ON os.id_os = op.id_os
WHERE os.data_entrada >= DATEADD(MONTH, -6, GETDATE())
GROUP BY 
    p.id_peca,
    p.descricao,
    p.fabricante,
    p.estoque_atual
ORDER BY saldo_estoque ASC;



