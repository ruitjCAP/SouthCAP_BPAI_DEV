--- OperationUser

CREATE TABLE LOG.OperationUser
(   
    LOG_ID     BIGINT IDENTITY(1,1) NOT NULL,
    UserCode   INT NOT NULL,
    UserName   VARCHAR(255),
    UserType   VARCHAR(50),
    IsActive   BIT,
    CreatedAt  DATETIME2(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy  VARCHAR(100),
    UpdatedAt  DATETIME2(3),
    UpdatedBy  VARCHAR(100),

    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,
    CONSTRAINT PK_LOG_OperationUser PRIMARY KEY CLUSTERED
    (
        LOG_ID ASC
    )
);


-- Calculation 

CREATE TABLE LOG.Calculation
(
    LOG_ID  BIGINT IDENTITY(1,1) NOT NULL,
    CalculationId INT NOT NULL,
    CalculationCode VARCHAR(255) NOT NULL,
    ItemId INT NOT NULL,
    CalculationOrder INT NULL,
    CalculationType VARCHAR(50) NULL,
    IsActive BIT NULL,
    CalculationDescription NVARCHAR(1000) NULL,

    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Calculation_CreatedAt
        DEFAULT (GETDATE()),

    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_Calculation_CreatedBy
        DEFAULT (SUSER_SNAME()),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,

    CONSTRAINT PK_LOG_Calculation
        PRIMARY KEY (LOG_ID),

);


-- ConfigEntity
CREATE TABLE LOG.ConfigEntity(
    LOG_ID     BIGINT IDENTITY(1,1) NOT NULL,
    EntityId INT  NOT NULL,
    ParentEntityId INT NULL,
    EntityName NVARCHAR(255) NOT NULL,
    EntityType VARCHAR(100) NULL,
    EntityDescription NVARCHAR(1000) NULL,
    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_DimEntity_CreatedAt DEFAULT (GETDATE()),
    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_DimEntity_CreatedBy DEFAULT (SUSER_SNAME()),
    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,

    CONSTRAINT PK_LOG_DimEntity
        PRIMARY KEY (LOG_ID),
);


-- ConfigItem
CREATE TABLE LOG.ConfigItem
(
    LOG_ID     BIGINT IDENTITY(1,1) NOT NULL,
    ItemId INT NOT NULL,
    TableId INT NOT NULL,
    ItemName NVARCHAR(255) NOT NULL,
    ParentItemID INT NULL,
    ItemType VARCHAR(20) NULL,
    ItemOrder INT NULL,
    InputType VARCHAR(50) NULL,
    DataType VARCHAR(50) NULL,
    ItemDescription NVARCHAR(1000) NULL,

    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_DimItem_CreatedAt
        DEFAULT (GETDATE()),

    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_DimItem_CreatedBy
        DEFAULT (SUSER_SNAME()),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,

    CONSTRAINT PK_LOG_DimItem
        PRIMARY KEY (LOG_ID),
);


-- ConfigTable
CREATE TABLE LOG.ConfigTable
(
    LOG_ID     BIGINT IDENTITY(1,1) NOT NULL,
    TableId INT  NOT NULL,
    TableName NVARCHAR(255) NOT NULL,
    TableSheetName NVARCHAR(255) NOT NULL,
    TableFileName NVARCHAR(255) NOT NULL,
    TableDescription NVARCHAR(1000) NULL,
    TableType NVARCHAR(50) NULL,

    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_ConfigTable_CreatedAt DEFAULT GETDATE(),

    CreatedBy VARCHAR(100) NOT NULL CONSTRAINT DF_ConfigTable_CreatedBy DEFAULT SUSER_SNAME(),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,

    CONSTRAINT PK_LOG_ConfigTable PRIMARY KEY (LOG_ID)
);


-- Version
CREATE TABLE LOG.Version
(
    LOG_ID     BIGINT IDENTITY(1,1) NOT NULL,
    VersionId INT NOT NULL,
    VersionCode VARCHAR(50) NOT NULL,
    VersionName NVARCHAR(255) NULL,
    VersionStatus VARCHAR(50) NULL,
    IsPublished BIT NULL,
    PublicationDate DATETIME2(3) NULL,

    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Version_CreatedAt
        DEFAULT (GETDATE()),

    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_Version_CreatedBy
        DEFAULT (SUSER_SNAME()),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,
    CONSTRAINT PK_LOG_Version
        PRIMARY KEY (LOG_ID)
);

-- LOG_AI DeviationsAnomalies

CREATE SCHEMA LOG_AI;

CREATE TABLE LOG_AI.DeviationsAnomalies
(
    LOG_ID  BIGINT IDENTITY(1,1) NOT NULL,
    DevAnId INT NOT NULL,
    TableId INT NOT NULL,
    ItemId INT NOT NULL,
    EntityId INT NOT NULL,

    DeviationThreshold NVARCHAR(200) NULL,
    AnomalieThreshold NVARCHAR(200) NULL,
    ItemImportance INT NOT NULL,
    Formula NVARCHAR(200) NULL,
    ContributingVariables NVARCHAR(200) NULL,

    CreatedAt DATETIME2(3) NOT NULL,
    CreatedBy VARCHAR(100) NOT NULL,
    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,
    LOG_Operation varchar(10) NOT NULL,
    LOG_ModifiedON datetime NOT NULL,
    LOG_ModifiedBy varchar(50) NOT NULL,

    CONSTRAINT PK_LOG_DeviationsAnomalies
        PRIMARY KEY (LOG_ID),

);