CREATE TABLE [CFG].[Version] (
    [VersionId]       INT            IDENTITY (1, 1) NOT NULL,
    [VersionCode]     VARCHAR (50)   NOT NULL,
    [VersionName]     NVARCHAR (255) NULL,
    [VersionStatus]   VARCHAR (50)   NULL,
    [IsPublished]     BIT            NULL,
    [PublicationDate] DATETIME2 (3)  NULL,
    [CreatedAt]       DATETIME2 (3)  CONSTRAINT [DF_Version_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (100)  CONSTRAINT [DF_Version_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]       DATETIME2 (3)  NULL,
    [UpdatedBy]       VARCHAR (100)  NULL,
    CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED ([VersionId] ASC)
);


GO

CREATE TRIGGER CFG.Version_TRG_DEL
   ON CFG.Version
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.Version
           (VersionId 
            ,VersionCode 
            ,VersionName 
            ,VersionStatus 
            ,IsPublished 
            ,PublicationDate 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy
            )
    SELECT VersionId 
            ,VersionCode 
            ,VersionName 
            ,VersionStatus 
            ,IsPublished 
            ,PublicationDate 
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

CREATE TRIGGER CFG.Version_TRG_UPD
   ON CFG.Version
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.Version
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.Version TB
    INNER JOIN inserted i ON TB.VersionId = i.VersionId;
 
 
    INSERT INTO LOG.Version
           (VersionId 
            ,VersionCode 
            ,VersionName 
            ,VersionStatus 
            ,IsPublished 
            ,PublicationDate 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy
            )
    SELECT VersionId 
            ,VersionCode 
            ,VersionName 
            ,VersionStatus 
            ,IsPublished 
            ,PublicationDate 
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

