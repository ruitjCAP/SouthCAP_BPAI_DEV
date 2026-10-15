CREATE TABLE [CFG].[ConfigItem] (
    [ItemId]          INT             IDENTITY (1, 1) NOT NULL,
    [TableId]         INT             NOT NULL,
    [ItemName]        NVARCHAR (255)  NOT NULL,
    [ParentItemID]    INT             NULL,
    [ItemType]        VARCHAR (20)    NULL,
    [ItemOrder]       INT             NULL,
    [InputType]       VARCHAR (50)    NULL,
    [DataType]        VARCHAR (50)    NULL,
    [ItemMandatory]   BIT             DEFAULT ((0)) NOT NULL,
    [ItemDescription] NVARCHAR (1000) NULL,
    [CreatedAt]       DATETIME2 (3)   CONSTRAINT [DF_DimItem_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (100)   CONSTRAINT [DF_DimItem_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]       DATETIME2 (3)   NULL,
    [UpdatedBy]       VARCHAR (100)   NULL,
    CONSTRAINT [PK_ConfigItem] PRIMARY KEY CLUSTERED ([ItemId] ASC),
    CONSTRAINT [FK_ConfigItem_ConfigTable] FOREIGN KEY ([TableId]) REFERENCES [CFG].[ConfigTable] ([TableId]),
    CONSTRAINT [FK_ConfigItem_ParentItem] FOREIGN KEY ([ParentItemID]) REFERENCES [CFG].[ConfigItem] ([ItemId])
);


GO

CREATE TRIGGER CFG.ConfigItem_TRG_DEL
   ON CFG.ConfigItem
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.ConfigItem
           (ItemId
            ,TableId 
            ,ItemName 
            ,ParentItemID 
            ,ItemType 
            ,ItemOrder 
            ,InputType 
            ,DataType
            ,ItemDescription 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy 
            )
    SELECT ItemId
            ,TableId 
            ,ItemName 
            ,ParentItemID 
            ,ItemType 
            ,ItemOrder 
            ,InputType 
            ,DataType
            ,ItemDescription 
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

CREATE TRIGGER CFG.ConfigItem_TRG_UPD
   ON CFG.ConfigItem
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.ConfigItem
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.ConfigItem TB
    INNER JOIN inserted i ON TB.ItemId = i.ItemId;
 
 
    INSERT INTO LOG.ConfigItem
           (ItemId
            ,TableId 
            ,ItemName 
            ,ParentItemID 
            ,ItemType 
            ,ItemOrder 
            ,InputType 
            ,DataType
            ,ItemDescription 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy 
            )
    SELECT ItemId
            ,TableId 
            ,ItemName 
            ,ParentItemID 
            ,ItemType 
            ,ItemOrder 
            ,InputType 
            ,DataType
            ,ItemDescription 
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

