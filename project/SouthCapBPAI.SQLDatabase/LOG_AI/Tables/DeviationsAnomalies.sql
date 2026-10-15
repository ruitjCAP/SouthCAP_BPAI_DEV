CREATE TABLE [LOG_AI].[DeviationsAnomalies] (
    [LOG_ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [DevAnId]               INT            NOT NULL,
    [TableId]               INT            NOT NULL,
    [ItemId]                INT            NOT NULL,
    [EntityId]              INT            NOT NULL,
    [DeviationThreshold]    NVARCHAR (200) NULL,
    [AnomalieThreshold]     NVARCHAR (200) NULL,
    [ItemImportance]        INT            NOT NULL,
    [Formula]               NVARCHAR (200) NULL,
    [ContributingVariables] NVARCHAR (200) NULL,
    [CreatedAt]             DATETIME2 (3)  NOT NULL,
    [CreatedBy]             VARCHAR (100)  NOT NULL,
    [UpdatedAt]             DATETIME2 (3)  NULL,
    [UpdatedBy]             VARCHAR (100)  NULL,
    [LOG_Operation]         VARCHAR (10)   NOT NULL,
    [LOG_ModifiedON]        DATETIME       NOT NULL,
    [LOG_ModifiedBy]        VARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_LOG_DeviationsAnomalies] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

