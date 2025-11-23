CREATE TABLE Peca (
    id_peca INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    fabricante VARCHAR(100),
    valor_unitario DECIMAL(8,2) NOT NULL,
    estoque_atual INT DEFAULT 0,
    estoque_minimo INT DEFAULT 1,
    CHECK (valor_unitario > 0)
);