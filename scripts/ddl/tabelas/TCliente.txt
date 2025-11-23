CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(255),
    data_cadastro DATE DEFAULT GETDATE()
);