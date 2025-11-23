CREATE TABLE OrdemServico (
    id_os INT IDENTITY(1,1) PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_mecanico INT NOT NULL,
    data_entrada DATE DEFAULT GETDATE(),
    data_saida DATE NULL,
    status VARCHAR(20) DEFAULT 'Aberta',
    observacoes TEXT,
    FOREIGN KEY (id_veiculo) REFERENCES Veiculo(id_veiculo),
    FOREIGN KEY (id_mecanico) REFERENCES Mecanico(id_mecanico),
    CHECK (data_saida IS NULL OR data_saida >= data_entrada)
);