CREATE SCHEMA BRZ;

CREATE SCHEMA ADT;

CREATE SCHEMA LOG;

CREATE SCHEMA CFGAI;

CREATE TABLE CFG.Mapping(
	MappingId int IDENTITY(1,1) NOT NULL,
	Code varchar(50) NULL,
	IDNormalizacao varchar(50) NULL,
	Ficheiro varchar(100) NOT NULL,
	Sheet varchar(100) NOT NULL,
	Tabela varchar(200) NOT NULL,
	Campo varchar(200) NOT NULL,
	Formato varchar(100) NULL,
	TipoInput varchar(200) NULL,
	TOC bit NULL,
	OPE bit NULL,
	NOS bit NULL,
	MAXIRENT bit NULL,
	CIM bit NULL,
	EIF bit NULL,
	SC bit NULL,
	TORDELIS bit NULL,
	LigacoesExternas varchar(max) NULL,
	Calculos varchar(max) NULL,
	MomentoExecucao int NULL,
	Observacoes varchar(max) NULL,
	CreatedDate datetime2(0) NOT NULL,
	ModifiedDate datetime2(0) NULL,
    CONSTRAINT PK_Mapping PRIMARY KEY (MappingId)
)

CREATE TABLE CFG.OperationUser
(   
    UserCode   INT IDENTITY(1,1) NOT NULL,
    UserName   VARCHAR(255),
    UserType   VARCHAR(50),
    IsActive   BIT,
    CreatedAt  DATETIME2(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy  VARCHAR(100),
    UpdatedAt  DATETIME2(3),
    UpdatedBy  VARCHAR(100),

    CONSTRAINT PK_OperationUser PRIMARY KEY (UserCode)
);



CREATE TABLE CFG.ConfigTable
(
    TableId INT IDENTITY(1,1) NOT NULL,
    TableName NVARCHAR(255) NOT NULL,
    TableSheetName NVARCHAR(255) NOT NULL,
    TableFileName NVARCHAR(255) NOT NULL,
    TableDescription NVARCHAR(1000) NULL,
    TableType NVARCHAR(50) NULL,

    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_ConfigTable_CreatedAt DEFAULT GETDATE(),

    CreatedBy VARCHAR(100) NOT NULL CONSTRAINT DF_ConfigTable_CreatedBy DEFAULT SUSER_SNAME(),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_ConfigTable PRIMARY KEY (TableId)
);




CREATE TABLE CFG.ConfigEntity(
    EntityId INT IDENTITY(1,1) NOT NULL,
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

    CONSTRAINT PK_DimEntity
        PRIMARY KEY (EntityId),

    CONSTRAINT FK_ConfigEntity_ParentEntity
        FOREIGN KEY (ParentEntityId)
        REFERENCES BRZ.ConfigEntity (EntityId)
);



CREATE TABLE CFG.ConfigItem
(
    ItemId INT IDENTITY(1,1) NOT NULL,
    TableId INT NOT NULL,
    ItemName NVARCHAR(255) NOT NULL,
    ParentItemID INT NULL,
    ItemType VARCHAR(20) NULL,
    ItemOrder INT NULL,
    InputType VARCHAR(50) NULL,
    DataType VARCHAR(50) NULL,
    ItemMandatory bit NOT NULL
    ItemDescription NVARCHAR(1000) NULL,

    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_DimItem_CreatedAt
        DEFAULT (GETDATE()),

    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_DimItem_CreatedBy
        DEFAULT (SUSER_SNAME()),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_DimItem
        PRIMARY KEY (ItemId),

    CONSTRAINT FK_ConfigItem_ConfigTable
        FOREIGN KEY (TableId)
        REFERENCES BRZ.ConfigTable (TableId),

    CONSTRAINT FK_ConfigItem_ParentItem
        FOREIGN KEY (ParentItemID)
        REFERENCES BRZ.ConfigItem (ItemId)
);


CREATE TABLE CFG.Calculation
(
    CalculationId INT IDENTITY(1,1) NOT NULL,
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

    CONSTRAINT PK_Calculation
        PRIMARY KEY (CalculationId),

    CONSTRAINT FK_Calculation_ConfigItem
        FOREIGN KEY (ItemId)
        REFERENCES BRZ.ConfigItem (ItemId)
);


CREATE TABLE CFG.Version
(
    VersionId INT IDENTITY(1,1) NOT NULL,
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

    CONSTRAINT PK_Version
        PRIMARY KEY (VersionId)
);


CREATE TABLE CFG.CalculationRun
(
    CalculationRunId BIGINT IDENTITY(1,1) NOT NULL,
    CalculationId INT NOT NULL,
    VersionId INT NOT NULL,
    RunStatus VARCHAR(50) NULL,
    StartedAt DATETIME2(3) NULL,
    EndedAt DATETIME2(3) NULL,
    ExecutedBy VARCHAR(100) NULL,
    ExecutionMessage NVARCHAR(2000) NULL,

    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_CalculationRun_CreatedAt
        DEFAULT (GETDATE()),

    CreatedBy VARCHAR(100) NOT NULL
        CONSTRAINT DF_CalculationRun_CreatedBy
        DEFAULT (SUSER_SNAME()),

    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_CalculationRun
        PRIMARY KEY (CalculationRunId),

    CONSTRAINT FK_CalculationRun_Calculation
        FOREIGN KEY (CalculationId)
        REFERENCES BRZ.Calculation (CalculationId),

    CONSTRAINT FK_CalculationRun_Version
        FOREIGN KEY (VersionId)
        REFERENCES BRZ.Version (VersionId)
);

CREATE TABLE CFG.RelTableAsset
(
    RelTAId INT IDENTITY(1,1) NOT NULL,
    TableId INT NOT NULL,
    EntityId INT NOT NULL,

    CreatedAt DATETIME2(3) NOT NULL,
    CreatedBy VARCHAR(100) NOT NULL,
    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_RelTableAsset
        PRIMARY KEY (RelTAId),

    CONSTRAINT FK_RelTableAsset_ConfigTable
        FOREIGN KEY (TableId)
        REFERENCES BRZ.ConfigTable (TableId),

    CONSTRAINT FK_RelTableAsset_ConfigEntity
        FOREIGN KEY (EntityId)
        REFERENCES BRZ.ConfigEntity (EntityId)
);


CREATE TABLE CFG.RelItemAsset
(
    RelIAId INT IDENTITY(1,1) NOT NULL,
    ItemId INT NOT NULL,
    EntityId INT NOT NULL,

    CreatedAt DATETIME2(3) NOT NULL,
    CreatedBy VARCHAR(100) NOT NULL,
    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_RelItemAsset
        PRIMARY KEY (RelIAId),

    CONSTRAINT FK_RelItemAsset_ConfigItem
        FOREIGN KEY (ItemId)
        REFERENCES BRZ.ConfigItem (ItemId),

    CONSTRAINT FK_RelItemAsset_ConfigEntity
        FOREIGN KEY (EntityId)
        REFERENCES BRZ.ConfigEntity (EntityId)
);


CREATE TABLE CFGAI.DeviationsAnomalies
(
    DevAnId INT IDENTITY(1,1) NOT NULL,
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

    CONSTRAINT PK_DeviationsAnomalies
        PRIMARY KEY (DevAnId),

    CONSTRAINT FK_DeviationsAnomalies_ConfigTable
        FOREIGN KEY (TableId)
        REFERENCES BRZ.ConfigTable (TableId),

    CONSTRAINT FK_DeviationsAnomalies_ConfigItem
        FOREIGN KEY (ItemId)
        REFERENCES BRZ.ConfigItem (ItemId),

    CONSTRAINT FK_DeviationsAnomalies_ConfigEntity
        FOREIGN KEY (EntityId)
        REFERENCES BRZ.ConfigEntity (EntityId)
);


CREATE TABLE LOG.Ingest
(
    IngestId BIGINT IDENTITY(1,1) NOT NULL,
    TableId INT NOT NULL,
    VersionId INT NOT NULL,
    CalculationRunId BIGINT NULL,

    IngestStatus VARCHAR(50) NOT NULL,
    StartedAt DATETIME2(3) NOT NULL,
    EndedAt DATETIME2(3) NULL,
    DurationSeconds INT NULL,

    RecordsRead BIGINT NULL,
    RecordsInserted BIGINT NULL,
    RecordsUpdated BIGINT NULL,
    RecordsRejected BIGINT NULL,

    SourceFileName NVARCHAR(255) NULL,
    SourceSheetName NVARCHAR(255) NULL,
    SourceLocation NVARCHAR(1000) NULL,

    ErrorCode VARCHAR(100) NULL,
    ErrorMessage NVARCHAR(2000) NULL,

    ExecutedBy VARCHAR(100) NULL,
    ExecutionHost VARCHAR(255) NULL,

    CreatedAt DATETIME2(3) NOT NULL,
    CreatedBy VARCHAR(100) NOT NULL,
    UpdatedAt DATETIME2(3) NULL,
    UpdatedBy VARCHAR(100) NULL,

    CONSTRAINT PK_Ingest
        PRIMARY KEY (IngestId),

    CONSTRAINT FK_Ingest_ConfigTable
        FOREIGN KEY (TableId)
        REFERENCES BRZ.ConfigTable (TableId),

    CONSTRAINT FK_Ingest_Version
        FOREIGN KEY (VersionId)
        REFERENCES BRZ.Version (VersionId),

    CONSTRAINT FK_Ingest_CalculationRun
        FOREIGN KEY (CalculationRunId)
        REFERENCES BRZ.CalculationRun (CalculationRunId)
);

