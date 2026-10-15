CREATE TABLE [CFG].[RelTableAsset] (
    [RelTAId]   INT           IDENTITY (1, 1) NOT NULL,
    [TableId]   INT           NOT NULL,
    [EntityId]  INT           NOT NULL,
    [CreatedAt] DATETIME2 (3) NOT NULL,
    [CreatedBy] VARCHAR (100) NOT NULL,
    [UpdatedAt] DATETIME2 (3) NULL,
    [UpdatedBy] VARCHAR (100) NULL,
    CONSTRAINT [PK_RelTableAsset] PRIMARY KEY CLUSTERED ([RelTAId] ASC),
    CONSTRAINT [FK_RelTableAsset_ConfigEntity] FOREIGN KEY ([EntityId]) REFERENCES [CFG].[ConfigEntity] ([EntityId]),
    CONSTRAINT [FK_RelTableAsset_ConfigTable] FOREIGN KEY ([TableId]) REFERENCES [CFG].[ConfigTable] ([TableId])
);


GO

