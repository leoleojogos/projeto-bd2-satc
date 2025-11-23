CREATE TABLE Veiculo (
    id_veiculo INT IDENTITY(1,1) PRIMARY KEY,
    placa VARCHAR(8) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano INT,
    cor VARCHAR(30),
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CHECK (ano >= 1900 AND ano <= YEAR(GETDATE()) + 1)
);