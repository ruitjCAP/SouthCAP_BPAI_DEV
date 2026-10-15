CREATE TABLE [CFG].[Calculation] (
    [CalculationId]          INT             IDENTITY (1, 1) NOT NULL,
    [CalculationCode]        VARCHAR (255)   NOT NULL,
    [ItemId]                 INT             NOT NULL,
    [CalculationOrder]       INT             NULL,
    [CalculationType]        VARCHAR (50)    NULL,
    [IsActive]               BIT             NULL,
    [CalculationDescription] NVARCHAR (1000) NULL,
    [CreatedAt]              DATETIME2 (3)   CONSTRAINT [DF_Calculation_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              VARCHAR (100)   CONSTRAINT [DF_Calculation_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]              DATETIME2 (3)   NULL,
    [UpdatedBy]              VARCHAR (100)   NULL,
    CONSTRAINT [PK_Calculation] PRIMARY KEY CLUSTERED ([CalculationId] ASC)
);


GO

CREATE TRIGGER CFG.Calculation_TRG_DEL
   ON CFG.Calculation
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.Calculation
           (CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,LOG_Operation
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy)
    SELECT CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,'DEL'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
 
END

GO

CREATE TRIGGER CFG.Calculation_TRG_UPD
   ON CFG.Calculation
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.Calculation
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.Calculation TB
    INNER JOIN inserted i ON TB.CalculationId = i.CalculationId;
 
 
    INSERT INTO LOG.Calculation
           (CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,LOG_Operation
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy)
    SELECT CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,'UPD'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
 
END

GO

