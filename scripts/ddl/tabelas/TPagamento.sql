CREATE TABLE Pagamento (
    id_pagamento INT IDENTITY(1,1) PRIMARY KEY,
    id_os INT NOT NULL,
    metodo_pagamento VARCHAR(20) NOT NULL,
    data_pagamento DATETIME,
    status_pagamento VARCHAR(20) DEFAULT 'Pendente',
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os)
);