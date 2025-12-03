CREATE OR ALTER FUNCTION dbo.fn_classifica_criticidade_cliente (
    @QtdManutencoes INT,
    @ValorTotal DECIMAL(18,2)
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @Nivel VARCHAR(10);
    
    IF (@QtdManutencoes >= 10 OR @ValorTotal >= 10000)
        SET @Nivel = 'Alta';
    ELSE IF (@QtdManutencoes >= 5 OR @ValorTotal >= 5000)
        SET @Nivel = 'Média';
    ELSE
        SET @Nivel = 'Baixa';
    
    RETURN @Nivel;
END;
GO