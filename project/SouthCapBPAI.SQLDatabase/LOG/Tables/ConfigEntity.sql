CREATE TABLE [LOG].[ConfigEntity] (
    [LOG_ID]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [EntityId]          INT             NOT NULL,
    [ParentEntityId]    INT             NULL,
    [EntityName]        NVARCHAR (255)  NOT NULL,
    [EntityType]        VARCHAR (100)   NULL,
    [EntityDescription] NVARCHAR (1000) NULL,
    [CreatedAt]         DATETIME2 (3)   CONSTRAINT [DF_DimEntity_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (100)   CONSTRAINT [DF_DimEntity_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]         DATETIME2 (3)   NULL,
    [UpdatedBy]         VARCHAR (100)   NULL,
    [LOG_Operation]     VARCHAR (10)    NOT NULL,
    [LOG_ModifiedON]    DATETIME        NOT NULL,
    [LOG_ModifiedBy]    VARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_LOG_DimEntity] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

