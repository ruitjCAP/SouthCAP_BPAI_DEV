CREATE TABLE [LOG].[Version] (
    [LOG_ID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [VersionId]       INT            NOT NULL,
    [VersionCode]     VARCHAR (50)   NOT NULL,
    [VersionName]     NVARCHAR (255) NULL,
    [VersionStatus]   VARCHAR (50)   NULL,
    [IsPublished]     BIT            NULL,
    [PublicationDate] DATETIME2 (3)  NULL,
    [CreatedAt]       DATETIME2 (3)  CONSTRAINT [DF_Version_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (100)  CONSTRAINT [DF_Version_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]       DATETIME2 (3)  NULL,
    [UpdatedBy]       VARCHAR (100)  NULL,
    [LOG_Operation]   VARCHAR (10)   NOT NULL,
    [LOG_ModifiedON]  DATETIME       NOT NULL,
    [LOG_ModifiedBy]  VARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_LOG_Version] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

