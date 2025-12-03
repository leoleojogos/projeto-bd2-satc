CREATE TABLE Agendamento (
    id_agendamento INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_veiculo INT NOT NULL,
    data_agendada DATE NOT NULL,
    hora_agendada TIME NOT NULL,
    id_mecanico INT,
    status_agendamento VARCHAR(20) DEFAULT 'Agendado',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_veiculo) REFERENCES Veiculo(id_veiculo),
    FOREIGN KEY (id_mecanico) REFERENCES Mecanico(id_mecanico),
);