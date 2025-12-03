CREATE NONCLUSTERED INDEX idx_peca_estoque 
ON Peca (estoque_atual, estoque_minimo)
WHERE estoque_atual <= estoque_minimo;
