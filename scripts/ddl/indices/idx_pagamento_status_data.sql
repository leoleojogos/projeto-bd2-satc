CREATE NONCLUSTERED INDEX idx_pagamento_status_data 
ON Pagamento (status_pagamento, data_pagamento DESC);
