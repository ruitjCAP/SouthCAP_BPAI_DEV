CREATE TABLE [LOG].[Ingest] (
    [IngestId]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [TableId]          INT             NOT NULL,
    [VersionId]        INT             NOT NULL,
    [CalculationRunId] BIGINT          NULL,
    [IngestStatus]     VARCHAR (50)    NOT NULL,
    [StartedAt]        DATETIME2 (3)   NOT NULL,
    [EndedAt]          DATETIME2 (3)   NULL,
    [DurationSeconds]  INT             NULL,
    [RecordsRead]      BIGINT          NULL,
    [RecordsInserted]  BIGINT          NULL,
    [RecordsUpdated]   BIGINT          NULL,
    [RecordsRejected]  BIGINT          NULL,
    [SourceFileName]   NVARCHAR (255)  NULL,
    [SourceSheetName]  NVARCHAR (255)  NULL,
    [SourceLocation]   NVARCHAR (1000) NULL,
    [ErrorCode]        VARCHAR (100)   NULL,
    [ErrorMessage]     NVARCHAR (2000) NULL,
    [ExecutedBy]       VARCHAR (100)   NULL,
    [ExecutionHost]    VARCHAR (255)   NULL,
    [CreatedAt]        DATETIME2 (3)   NOT NULL,
    [CreatedBy]        VARCHAR (100)   NOT NULL,
    [UpdatedAt]        DATETIME2 (3)   NULL,
    [UpdatedBy]        VARCHAR (100)   NULL,
    CONSTRAINT [PK_Ingest] PRIMARY KEY CLUSTERED ([IngestId] ASC),
    CONSTRAINT [FK_Ingest_CalculationRun] FOREIGN KEY ([CalculationRunId]) REFERENCES [CFG].[CalculationRun] ([CalculationRunId]),
    CONSTRAINT [FK_Ingest_ConfigTable] FOREIGN KEY ([TableId]) REFERENCES [CFG].[ConfigTable] ([TableId]),
    CONSTRAINT [FK_Ingest_Version] FOREIGN KEY ([VersionId]) REFERENCES [CFG].[Version] ([VersionId])
);


GO

