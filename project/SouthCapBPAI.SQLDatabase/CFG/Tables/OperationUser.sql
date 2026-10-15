CREATE TABLE [CFG].[OperationUser] (
    [UserCode]  INT           IDENTITY (1, 1) NOT NULL,
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

GO

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

GO

