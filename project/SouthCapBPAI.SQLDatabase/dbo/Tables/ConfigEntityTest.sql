CREATE TABLE [dbo].[ConfigEntityTest] (
    [EntityId]          INT             IDENTITY (1, 1) NOT NULL,
    [ParentEntityId]    INT             NULL,
    [EntityName]        NVARCHAR (255)  NOT NULL,
    [EntityType]        VARCHAR (100)   NULL,
    [EntityDescription] NVARCHAR (1000) NULL,
    [CreatedAt]         DATETIME2 (3)   CONSTRAINT [DF_DimEntity_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (100)   CONSTRAINT [DF_DimEntity_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]         DATETIME2 (3)   NULL,
    [UpdatedBy]         VARCHAR (100)   NULL,
    CONSTRAINT [PK_DimEntity] PRIMARY KEY CLUSTERED ([EntityId] ASC)
);


GO

