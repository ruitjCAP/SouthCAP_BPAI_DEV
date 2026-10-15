-- OperationUser

CREATE TRIGGER CFG.OperationUser_TRG_DEL
   ON CFG.OperationUser
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.OperationUser
           (UserCode 
            ,UserName 
            ,UserType 
            ,IsActive 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
           ,LOG_Operation
           ,LOG_ModifiedON
           ,LOG_ModifiedBy)
    SELECT UserCode 
            ,UserName 
            ,UserType 
            ,IsActive 
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,'DEL'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
END


-- Calculation

CREATE TRIGGER CFG.Calculation_TRG_DEL
   ON CFG.Calculation
   AFTER DELETE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    INSERT INTO LOG.Calculation
           (CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,LOG_Operation
            ,LOG_ModifiedON 
            ,LOG_ModifiedBy)
    SELECT CalculationId
            ,CalculationCode
            ,ItemId
            ,CalculationOrder
            ,CalculationType
            ,IsActive
            ,CalculationDescription
            ,CreatedAt
            ,CreatedBy
            ,UpdatedAt
            ,UpdatedBy
            ,'DEL'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
 
END

-- ConfigEntity

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

-- ConfigItem

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

-- ConfigTable
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


-- Version
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


-- LOGAI DeviationsAnomalies

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