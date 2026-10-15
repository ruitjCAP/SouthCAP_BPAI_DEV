CREATE TABLE [LOG].[Calculation] (
    [LOG_ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [CalculationId]          INT             NOT NULL,
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
    [LOG_Operation]          VARCHAR (10)    NOT NULL,
    [LOG_ModifiedON]         DATETIME        NOT NULL,
    [LOG_ModifiedBy]         VARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_LOG_Calculation] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

