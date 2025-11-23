CREATE TABLE OS_Servico (
    id_os_servico INT IDENTITY(1,1) PRIMARY KEY,
    id_os INT NOT NULL,
    id_servico INT NOT NULL,
    quantidade INT DEFAULT 1,
    valor_unitario DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os) ON DELETE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES Servico(id_servico),
    CHECK (quantidade > 0),
    UNIQUE (id_os, id_servico)
);