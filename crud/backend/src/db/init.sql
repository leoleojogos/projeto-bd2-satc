-- TABELAS PARA SQL SERVER

CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(255),
    data_cadastro DATE DEFAULT GETDATE()
);

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

CREATE TABLE Mecanico (
    id_mecanico INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    ativo BIT DEFAULT 1
);

CREATE TABLE Servico (
    id_servico INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    valor_padrao DECIMAL(8,2) NOT NULL,
    tempo_estimado INT,
    ativo BIT DEFAULT 1,
    CHECK (valor_padrao > 0)
);

CREATE TABLE Peca (
    id_peca INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL,
    fabricante VARCHAR(100),
    valor_unitario DECIMAL(8,2) NOT NULL,
    estoque_atual INT DEFAULT 0,
    estoque_minimo INT DEFAULT 1,
    CHECK (valor_unitario > 0)
);

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

CREATE TABLE OS_Peca (
    id_os_peca INT IDENTITY(1,1) PRIMARY KEY,
    id_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT DEFAULT 1,
    valor_unitario DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os) ON DELETE CASCADE,
    FOREIGN KEY (id_peca) REFERENCES Peca(id_peca),
    CHECK (quantidade > 0),
    UNIQUE (id_os, id_peca)
);

CREATE TABLE Pagamento (
    id_pagamento INT IDENTITY(1,1) PRIMARY KEY,
    id_os INT NOT NULL,
    metodo_pagamento VARCHAR(20) NOT NULL,
    data_pagamento DATETIME,
    status_pagamento VARCHAR(20) DEFAULT 'Pendente',
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os)
);

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


CREATE UNIQUE NONCLUSTERED INDEX UQ_OS_Peca 
ON OS_Peca (id_os, id_peca);

CREATE UNIQUE NONCLUSTERED INDEX UQ_OS_Servico
ON OS_Servico (id_os, id_servico);

CREATE NONCLUSTERED INDEX idx_agendamento_cliente 
ON Agendamento (id_cliente);

CREATE NONCLUSTERED INDEX idx_agendamento_data 
ON Agendamento (data_agendada, hora_agendada);

CREATE NONCLUSTERED INDEX idx_agendamento_mecanico 
ON Agendamento (id_mecanico);

CREATE NONCLUSTERED INDEX idx_agendamento_status 
ON Agendamento (status_agendamento);

CREATE NONCLUSTERED INDEX idx_cliente_nome 
ON Cliente (nome);

CREATE NONCLUSTERED INDEX idx_mecanico_ativo 
ON Mecanico (ativo);

CREATE NONCLUSTERED INDEX idx_mecanico_nome 
ON Mecanico (nome);

CREATE NONCLUSTERED INDEX idx_mecanico_ordem 
ON OrdemServico (id_mecanico, id_os);

CREATE NONCLUSTERED INDEX idx_os_pagamento 
ON OrdemServico (id_veiculo, id_os);

CREATE NONCLUSTERED INDEX idx_os_peca_os 
ON OS_Peca (id_os);

CREATE NONCLUSTERED INDEX idx_os_peca_peca 
ON OS_Peca (id_peca);

CREATE NONCLUSTERED INDEX idx_os_peca_valor
ON OS_Peca (id_os, valor_unitario, quantidade);

CREATE NONCLUSTERED INDEX idx_os_servico_os 
ON OS_Servico (id_os);

CREATE NONCLUSTERED INDEX idx_os_servico_servico 
ON OS_Servico (id_servico);

CREATE NONCLUSTERED INDEX idx_os_servico_valor
ON OS_Servico (id_os, valor_unitario, quantidade);

CREATE NONCLUSTERED INDEX idx_pagamento_data_status 
ON Pagamento (data_pagamento, status_pagamento);

CREATE NONCLUSTERED INDEX idx_pagamento_metodo 
ON Pagamento (metodo_pagamento);

CREATE NONCLUSTERED INDEX idx_pagamento_status_data 
ON Pagamento (status_pagamento, data_pagamento DESC);

CREATE NONCLUSTERED INDEX idx_peca_descricao 
ON Peca (descricao);

CREATE NONCLUSTERED INDEX idx_peca_estoque 
ON Peca (estoque_atual, estoque_minimo)

CREATE NONCLUSTERED INDEX idx_peca_valor 
ON Peca (valor_unitario);

CREATE NONCLUSTERED INDEX idx_servico_ativo 
ON Servico (ativo);

CREATE NONCLUSTERED INDEX idx_servico_descricao 
ON Servico (descricao);

CREATE NONCLUSTERED INDEX idx_veiculo_placa 
ON Veiculo (placa);