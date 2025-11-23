CREATE TABLE Mecanico (
    id_mecanico INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    ativo BIT DEFAULT 1
);
