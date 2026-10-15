CREATE TABLE [CFG].[CalculationRun] (
    [CalculationRunId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CalculationId]    INT             NOT NULL,
    [VersionId]        INT             NOT NULL,
    [RunStatus]        VARCHAR (50)    NULL,
    [StartedAt]        DATETIME2 (3)   NULL,
    [EndedAt]          DATETIME2 (3)   NULL,
    [ExecutedBy]       VARCHAR (100)   NULL,
    [ExecutionMessage] NVARCHAR (2000) NULL,
    [CreatedAt]        DATETIME2 (3)   CONSTRAINT [DF_CalculationRun_CreatedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (100)   CONSTRAINT [DF_CalculationRun_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedAt]        DATETIME2 (3)   NULL,
    [UpdatedBy]        VARCHAR (100)   NULL,
    CONSTRAINT [PK_CalculationRun] PRIMARY KEY CLUSTERED ([CalculationRunId] ASC),
    CONSTRAINT [FK_CalculationRun_Calculation] FOREIGN KEY ([CalculationId]) REFERENCES [CFG].[Calculation] ([CalculationId]),
    CONSTRAINT [FK_CalculationRun_Version] FOREIGN KEY ([VersionId]) REFERENCES [CFG].[Version] ([VersionId])
);


GO

