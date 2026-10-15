
--- OperationUser
CREATE TRIGGER CFG.OperationUser_TRG_UPD
   ON CFG.OperationUser
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.OperationUser
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.OperationUser TB
    INNER JOIN inserted i ON TB.UserCode = i.UserCode;
 
 
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
            ,'UPD'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
 
END

-- Calculation 

CREATE TRIGGER CFG.Calculation_TRG_UPD
   ON CFG.Calculation
   AFTER UPDATE
AS
BEGIN
 
    SET NOCOUNT ON;
 
    UPDATE CFG.Calculation
    SET UpdatedAt = GETDATE(),
        UpdatedBy = SYSTEM_USER
    FROM CFG.Calculation TB
    INNER JOIN inserted i ON TB.CalculationId = i.CalculationId;
 
 
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
            ,'UPD'
            ,GETDATE()
            ,CONVERT(VARCHAR(50),SYSTEM_USER)
    FROM DELETED D
 
END

-- ConfigEntity

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

-- ConfigItem
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


-- ConfigTable
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

-- Version
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



-- LOGAI DeviationsAnomalies


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
