CREATE TABLE [CFG].[ConfigTable] (
    [TableId]          INT             IDENTITY (1, 1) NOT NULL,
    [TableName]        NVARCHAR (255)  NOT NULL,
    [TableSheetName]   NVARCHAR (255)  NOT NULL,
    [TableFileName]    NVARCHAR (255)  NOT NULL,
    [TableDescription] NVARCHAR (1000) NULL,
    [TableType]        NVARCHAR (50)   NULL,
    [CreatedAt]        DATETIME2 (3)   CONSTRAINT [DF_ConfigTable_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (100)   CONSTRAINT [DF_ConfigTable_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]        DATETIME2 (3)   NULL,
    [UpdatedBy]        VARCHAR (100)   NULL,
    CONSTRAINT [PK_ConfigTable] PRIMARY KEY CLUSTERED ([TableId] ASC)
);


GO

CREATE TRIGGER CFG.ConfigTable_TRG_DEL
   ON CFG.ConfigTable
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.ConfigTable
           (TableId 
            ,TableName 
            ,TableSheetName 
            ,TableFileName 
            ,TableDescription 
            ,TableType 
            ,CreatedAt 
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy
            )
    SELECT TableId 
            ,TableName 
            ,TableSheetName 
            ,TableFileName 
            ,TableDescription 
            ,TableType 
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

CREATE TRIGGER CFG.ConfigTable_TRG_UPD
   ON CFG.ConfigTable
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.ConfigTable
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.ConfigTable TB
    INNER JOIN inserted i ON TB.TableId = i.TableId;
 
 
    INSERT INTO LOG.ConfigTable
           (TableId 
            ,TableName 
            ,TableSheetName 
            ,TableFileName 
            ,TableDescription 
            ,TableType 
            ,CreatedAt 
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy
            )
    SELECT TableId 
            ,TableName 
            ,TableSheetName 
            ,TableFileName 
            ,TableDescription 
            ,TableType 
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

