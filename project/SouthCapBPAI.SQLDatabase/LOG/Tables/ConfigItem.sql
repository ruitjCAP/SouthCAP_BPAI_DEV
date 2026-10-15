CREATE TABLE [LOG].[ConfigItem] (
    [LOG_ID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ItemId]          INT             NOT NULL,
    [TableId]         INT             NOT NULL,
    [ItemName]        NVARCHAR (255)  NOT NULL,
    [ParentItemID]    INT             NULL,
    [ItemType]        VARCHAR (20)    NULL,
    [ItemOrder]       INT             NULL,
    [InputType]       VARCHAR (50)    NULL,
    [DataType]        VARCHAR (50)    NULL,
    [ItemDescription] NVARCHAR (1000) NULL,
    [CreatedAt]       DATETIME2 (3)   CONSTRAINT [DF_DimItem_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (100)   CONSTRAINT [DF_DimItem_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]       DATETIME2 (3)   NULL,
    [UpdatedBy]       VARCHAR (100)   NULL,
    [LOG_Operation]   VARCHAR (10)    NOT NULL,
    [LOG_ModifiedON]  DATETIME        NOT NULL,
    [LOG_ModifiedBy]  VARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_LOG_DimItem] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

