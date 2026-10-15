CREATE TABLE [LOG].[OperationUser] (
    [LOG_ID]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [UserCode]       INT           NOT NULL,
    [UserName]       VARCHAR (255) NULL,
    [UserType]       VARCHAR (50)  NULL,
    [IsActive]       BIT           NULL,
    [CreatedAt]      DATETIME2 (3) DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (100) NULL,
    [UpdatedAt]      DATETIME2 (3) NULL,
    [UpdatedBy]      VARCHAR (100) NULL,
    [LOG_Operation]  VARCHAR (10)  NOT NULL,
    [LOG_ModifiedON] DATETIME      NOT NULL,
    [LOG_ModifiedBy] VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_LOG_OperationUser] PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO

