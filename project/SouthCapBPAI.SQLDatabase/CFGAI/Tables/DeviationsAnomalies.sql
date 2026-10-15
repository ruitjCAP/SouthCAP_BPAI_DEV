CREATE TABLE [CFGAI].[DeviationsAnomalies] (
    [DevAnId]               INT            IDENTITY (1, 1) NOT NULL,
    [TableId]               INT            NOT NULL,
    [ItemId]                INT            NOT NULL,
    [EntityId]              INT            NOT NULL,
    [DeviationThreshold]    NVARCHAR (200) NULL,
    [AnomalieThreshold]     NVARCHAR (200) NULL,
    [ItemImportance]        INT            NOT NULL,
    [Formula]               NVARCHAR (200) NULL,
    [ContributingVariables] NVARCHAR (200) NULL,
    [CreatedAt]             DATETIME2 (3)  NOT NULL,
    [CreatedBy]             VARCHAR (100)  NOT NULL,
    [UpdatedAt]             DATETIME2 (3)  NULL,
    [UpdatedBy]             VARCHAR (100)  NULL,
    CONSTRAINT [PK_DeviationsAnomalies] PRIMARY KEY CLUSTERED ([DevAnId] ASC),
    CONSTRAINT [FK_DeviationsAnomalies_ConfigEntity] FOREIGN KEY ([EntityId]) REFERENCES [CFG].[ConfigEntity] ([EntityId]),
    CONSTRAINT [FK_DeviationsAnomalies_ConfigTable] FOREIGN KEY ([TableId]) REFERENCES [CFG].[ConfigTable] ([TableId])
);


GO

CREATE TRIGGER CFGAI.DeviationsAnomalies_TRG_DEL
   ON CFGAI.DeviationsAnomalies
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG_AI.DeviationsAnomalies
           (DevAnId 
            ,TableId 
            ,ItemId 
            ,EntityId
            ,DeviationThreshold 
            ,AnomalieThreshold 
            ,ItemImportance 
            ,Formula 
            ,ContributingVariables 
            ,CreatedAt 
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON
            ,LOG_ModifiedBy 
            )
    SELECT DevAnId 
            ,TableId 
            ,ItemId 
            ,EntityId
            ,DeviationThreshold 
            ,AnomalieThreshold 
            ,ItemImportance 
            ,Formula 
            ,ContributingVariables 
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

CREATE TRIGGER CFGAI.DeviationsAnomalies_TRG_UPD
   ON CFGAI.DeviationsAnomalies
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFGAI.DeviationsAnomalies
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFGAI.DeviationsAnomalies TB
    INNER JOIN inserted i ON TB.DevAnId = i.DevAnId;
 
    INSERT INTO LOG_AI.DeviationsAnomalies
           (DevAnId 
            ,TableId 
            ,ItemId 
            ,EntityId
            ,DeviationThreshold 
            ,AnomalieThreshold 
            ,ItemImportance 
            ,Formula 
            ,ContributingVariables 
            ,CreatedAt 
            ,CreatedBy 
            ,UpdatedAt 
            ,UpdatedBy 
            ,LOG_Operation 
            ,LOG_ModifiedON
            ,LOG_ModifiedBy 
            )
    SELECT DevAnId 
            ,TableId 
            ,ItemId 
            ,EntityId
            ,DeviationThreshold 
            ,AnomalieThreshold 
            ,ItemImportance 
            ,Formula 
            ,ContributingVariables 
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

