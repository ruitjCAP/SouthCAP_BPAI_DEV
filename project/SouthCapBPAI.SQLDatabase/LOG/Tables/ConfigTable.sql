CREATE TABLE [LOG].[ConfigTable] (
    [LOG_ID]           BIGINT          IDENTITY (1, 1) NOT NULL,
    [TableId]          INT             NOT NULL,
    [TableName]        NVARCHAR (255)  NOT NULL,
    [TableSheetName]   NVARCHAR (255)  NOT NULL,
    [TableFileName]    NVARCHAR (255)  NOT NULL,
    [TableDescription] NVARCHAR (1000) NULL,
    [TableType]        NVARCHAR (50)   NULL,
    [CreatedAt]        DATETIME2 (3)   CONSTRAINT [DF_ConfigTable_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (100)   CONSTRAINT [DF_ConfigTable_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]        DATETIME2 (3)   NULL,
    [UpdatedBy]        VARCHAR (100)   NULL,
    [LOG_Operation]    VARCHAR (10)    NOT NULL,
    [LOG_ModifiedON]   DATETIME        NOT NULL,
    [LOG_ModifiedBy]   VARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_LOG_ConfigTable] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

