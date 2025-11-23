CREATE TABLE Servico (
    id_servico INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    valor_padrao DECIMAL(8,2) NOT NULL,
    tempo_estimado INT,
    ativo BIT DEFAULT 1,
    CHECK (valor_padrao > 0)
);