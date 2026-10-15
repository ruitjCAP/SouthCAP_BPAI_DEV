CREATE TABLE [dbo].[OperationUserTest] (
    [UserCode]  INT           NOT NULL,
    [UserName]  VARCHAR (255) NULL,
    [UserType]  VARCHAR (50)  NULL,
    [IsActive]  BIT           NULL,
    [CreatedAt] DATETIME2 (3) DEFAULT (getdate()) NOT NULL,
    [CreatedBy] VARCHAR (100) NULL,
    [UpdatedAt] DATETIME2 (3) NULL,
    [UpdatedBy] VARCHAR (100) NULL,
    CONSTRAINT [PK_OperationUser] PRIMARY KEY CLUSTERED ([UserCode] ASC)
);


GO

