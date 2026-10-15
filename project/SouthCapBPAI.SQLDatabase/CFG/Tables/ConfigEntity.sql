CREATE TABLE [CFG].[ConfigEntity] (
    [EntityId]          INT             IDENTITY (1, 1) NOT NULL,
    [ParentEntityId]    INT             NULL,
    [EntityName]        NVARCHAR (255)  NOT NULL,
    [EntityType]        VARCHAR (100)   NULL,
    [EntityDescription] NVARCHAR (1000) NULL,
    [CreatedAt]         DATETIME2 (3)   CONSTRAINT [DF_DimEntity_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (100)   CONSTRAINT [DF_DimEntity_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]         DATETIME2 (3)   NULL,
    [UpdatedBy]         VARCHAR (100)   NULL,
    CONSTRAINT [PK_DimEntity] PRIMARY KEY CLUSTERED ([EntityId] ASC),
    CONSTRAINT [FK_ConfigEntity_ParentEntity] FOREIGN KEY ([ParentEntityId]) REFERENCES [CFG].[ConfigEntity] ([EntityId])
);


GO

CREATE TRIGGER CFG.ConfigEntity_TRG_DEL
   ON CFG.ConfigEntity
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.ConfigEntity
           (EntityId 
            ,ParentEntityId 
            ,EntityName 
            ,EntityType 
            ,EntityDescription 
            ,CreatedAt
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON
            ,LOG_ModifiedBy 
            )
    SELECT EntityId 
            ,ParentEntityId 
            ,EntityName 
            ,EntityType 
            ,EntityDescription 
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

CREATE TRIGGER CFG.ConfigEntity_TRG_UPD
   ON CFG.ConfigEntity
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.ConfigEntity
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.ConfigEntity TB
    INNER JOIN inserted i ON TB.EntityId = i.EntityId;
 
 
    INSERT INTO LOG.ConfigEntity
           (EntityId 
            ,ParentEntityId 
            ,EntityName 
            ,EntityType 
            ,EntityDescription 
            ,CreatedAt
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON
            ,LOG_ModifiedBy 
            )
    SELECT EntityId 
            ,ParentEntityId 
            ,EntityName 
            ,EntityType 
            ,EntityDescription 
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

