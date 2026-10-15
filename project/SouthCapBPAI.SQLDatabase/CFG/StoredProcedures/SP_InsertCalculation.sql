CREATE   PROCEDURE CFG.SP_InsertCalculation
    @CalculationCode        VARCHAR(255),
    @ItemId                 INT,
    @CalculationOrder       INT             = NULL,
    @CalculationType        VARCHAR(50)     = NULL,
    @IsActive               BIT             = 1,
    @CalculationDescription NVARCHAR(1000)  = NULL,
    @CreatedBy              VARCHAR(100)    = NULL
    
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.Calculation
        (CalculationCode, 
         ItemId,
         CalculationOrder,
         CalculationType,
         IsActive,
         CalculationDescription,
         CreatedBy)
    VALUES
        (@CalculationCode,
         @ItemId,
         @CalculationOrder,
         @CalculationType,
         @IsActive,
         @CalculationDescription,
         SYSTEM_USER);

END;

GO

