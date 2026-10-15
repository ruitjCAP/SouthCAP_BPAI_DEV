CREATE TABLE [CFG].[RelItemAsset] (
    [RelIAId]   INT           IDENTITY (1, 1) NOT NULL,
    [ItemId]    INT           NOT NULL,
    [EntityId]  INT           NOT NULL,
    [CreatedAt] DATETIME2 (3) NOT NULL,
    [CreatedBy] VARCHAR (100) NOT NULL,
    [UpdatedAt] DATETIME2 (3) NULL,
    [UpdatedBy] VARCHAR (100) NULL,
    CONSTRAINT [PK_RelItemAsset] PRIMARY KEY CLUSTERED ([RelIAId] ASC),
    CONSTRAINT [FK_RelItemAsset_ConfigEntity] FOREIGN KEY ([EntityId]) REFERENCES [CFG].[ConfigEntity] ([EntityId])
);


GO

